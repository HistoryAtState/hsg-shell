var locale;
var citationData;
var options = {
  retrieveLocale: function () {
    return locale;
  },
  retrieveItem: function (id) {
    return citationData;
  },
};
var cslDir = $('#cite-script').attr('src').split(/scripts\/.*\.js/).shift() + 'CSL/'
var localeUrl = cslDir;
var cslUrl = cslDir;
var citations = {
  chicago: '',
  mla: '',
  state: 'none',
}
var styleNames = {
  chicago: 'chicago-fullnote-bibliography',
  mla: 'modern-language-association',
}
var styles = {
  chicago: '',
  mla: '',
}
function baseCitation(id) {
  return {
    citationID: 'X',
    citationItems: [
      {
        id: id,
      }
    ],
    properties: {
      noteIndex: 1
    }
  };
}
function updateState(state) {
  citations.state = state;
}
jQuery(function ($) {
  function get(url, cb) {
    $.get(url, function (data) {
      cb(false, data);
    }, 'text').fail(function () {
      cb(true)
    });
  }
  function getLocale(lang, cb) {
    get(localeUrl + 'locale-' + lang + '.xml', cb);
  }
  function getCSL(style, cb) {
    get(localeUrl + styleNames[style] + '.csl', cb);
  }
  function prepareCitations(lang, cb) {
    try {
      updateState('loading');
      var alreadyFailed = false;
      citationData = JSON.parse($('#original_citation').html())[0];
      if (!locale) {
        getLocale(lang, function (error, _locale) {
          if (error) {
            failed();
          } else {
            locale = _locale;
            done();
          }
        });
      }
      if (!styles.chicago) {
        getCSL('chicago', function (error, cslChicago) {
          if (error) {
            failed();
          } else {
            styles.chicago = cslChicago;
            done();
          }
        });
      }
      if (!styles.mla) {
        getCSL('mla', function (error, cslMla) {
          if (error) {
            failed();
          } else {
            styles.mla = cslMla;
            done();
          }
        });
      }
      function done() {
        if (locale && styles.chicago && styles.mla) {
          updateState('ready');
          cb(false);
        }
      }
      function failed() {
        if (!alreadyFailed) {
          updateState('error');
          cb(true);
          alreadyFailed = true;
        }
      }
      done();
    } catch (error) {
      console.error(error);
      cb(true, error);
    }
  }
  function generateCitation(style, cb) {
    var citeproc = new CSL.Engine(options, styles[style]);
    var citationResult = citeproc.processCitationCluster(baseCitation(citationData.id), [], []);
    var citation_errors = citationResult[0].citation_errors;
    if (citation_errors.length) {
      citation_errors.forEach(function (err) {
        console.error(err);
      });
      cb(true, citation_errors);
    } else {
      cb(false, citeproc.makeBibliography()[1].join(''));
    }
  }
  function getCitation(style) {
    if (citations.state !== 'done') {
      console.error('citations not generated');
      return;
    }
    return citations[style];
  }
  function createUI() {
    var btnAnchor = $('.hsg-cite-button');
    $('body').append(
      '<div id="citationDialog" class="modal fade in" tabindex="-1" role="dialog" style="display: none; padding-right: 12px;">' +
      '  <div class="modal-dialog" role="document">' +
      '    <div class="modal-content">' +
      '      <div class="modal-header">' +
      '        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span' +
      '            aria-hidden="true">×</span></button>' +
      '        <h4 class="modal-title">Cite this resource</h4>' +
      '      </div>' +
      '      <div class="modal-body">' +
      '        <div class="row">' +
      '          <div class="form-group col-sm-12">' +
      '            <label>Chicago Fullnote Bibliography</label>' +
      '            <div data-style="chicago" class="form-control citation-text" contenteditable readonly style="height:auto"/>' +
      '            <div class="text-right"><button style="margin-top: 8px" type="button" class="btn btn-primary copy-button" data-style="chicago">Copy</button></div>' +
      '          </div>' +
      '          <div class="form-group col-sm-12">' +
      '            <label>Modern Language Association</label>' +
      '            <div data-style="mla" class="form-control citation-text" contenteditable readonly style="height:auto"/>' +
      '            <div class="text-right"><button style="margin-top: 8px" type="button" class="btn btn-primary copy-button" data-style="mla">Copy</button></div>' +
      '          </div>' +
      '        </div>' +
      '      </div>' +
      '      <div class="modal-footer">' +
      '        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button><span />' +
      '      </div>' +
      '    </div>' +
      '  </div>' +
      '</div>'
    );
    function copyToClipboard(source) {
      if (navigator.clipboard) {
        navigator.clipboard.write([new ClipboardItem({
          'text/plain': new Blob([getCitation(source.data('style')).text], { type: 'text/plain' }),
          'text/html': new Blob([getCitation(source.data('style')).html], { type: 'text/html' }),
        })]);
      } else {
        var div = $(source).children('div');
        if (document.selection) {
            var range = document.body.createTextRange();
            range.moveToElementText(div[0]);
            range.select();
        } else if (window.getSelection) {
            var range = document.createRange();
            range.selectNode(div[0]);
            window.getSelection().removeAllRanges();
            window.getSelection().addRange(range);
        }
        document.execCommand('copy');
      }
    }
    $('.copy-button').click(function (e) {
      copyToClipboard($(this).parent().prev());
    });
    init(function (error) {
      $('.citation-text').each(function (i, source) {
        source = $(source);
        source.html(getCitation(source.data('style')).html)
      });
      if (error) {
        btnAnchor.removeAttr('href');
        btn.html('Can not cite');
        return
      }
      btnAnchor.click(function (e) {
        e.preventDefault();
        $('#citationDialog').modal('show');
      });
    });
  }
  createUI();
  function init(cb) {
    prepareCitations('en-US', function (error) {
      function prepareCitation(citation) {
        citation = citation.trim();
        return {
          html: citation,
          text: $('<div>').html(citation).text(),
        };
      }
      if (error || citations.state !== 'ready') {
        failed();
        return;
      }
      updateState('generating');
      var alreadyFailed = false;
      if (!citations.mla) {
        generateCitation('mla', function (error, _mla) {
          if (error) {
            failed();
          } else {
            citations.mla = prepareCitation(_mla);
            done();
          }
        });
      }
      if (!citations.chicago) {
        generateCitation('chicago', function (error, _chicago) {
          if (error) {
            failed();
          } else {
            citations.chicago = prepareCitation(_chicago);
            done();
          }
        });
      }
      function done() {
        if (locale && citations.chicago && citations.mla) {
          updateState('done');
          cb()
        }
      }
      function failed() {
        if (!alreadyFailed) {
          updateState('error');
          console.error('can not generate citations');
          alreadyFailed = true;
          cb(true);
        }
      }
      done();
    });
  }
});