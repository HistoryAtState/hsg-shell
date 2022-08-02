jQuery(function ($) {
  $('body').append('<div id="touch-detector" />');
  $('body').append(
    '<div id="footnote-modal" class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">' +
    '  <div class="modal-dialog-container">' +
    '    <div class="modal-dialog" role="document">' +
    '      <div class="modal-content">' +
    '        <div class="modal-header">' +
    '          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
    '          <h4 class="modal-title" id="myModalLabel"><span class="glyphicon glyphicon-bookmark" aria-hidden="true"></span> Citation</h4>' +
    '        </div>' +
    '        <div class="modal-body">' +
    '          <div id="footnote"></div>' +
    '          <div id="link" class="text-right">' +
    '            <hr>' +
    '            <a href="#">View footnotes</a>' +
    '          </div>' +
    '        </div>' +
    '      </div>' +
    '    </div>' +
    '  </div>' +
    '</div>'
  );
  var parentSelector = 'body',
    footnoteAttribute = 'shown-footnote',
    popoverTimeout = 500,
    footnoteModalSelector = '#footnote-modal',
    footnoteSelector = 'a.note[rel=footnote]';
  function touchAvailable() {
    return $('#touch-detector').is(':visible');
  }
  function initFootnotes() {
    $(parentSelector).on('click', '.popover', function(event) {
      event.stopPropagation();
    });
    var footnoteTimer,
      footnotes = $(footnoteSelector),
      footnoteModal = $(footnoteModalSelector);
    function hideAll() {
      footnotes.popover('hide');
      $(parentSelector).off('click', hideAll);
      $(parentSelector).off('mousemove', mouseMove);
    }
    function mouseMove(event) {
      if ($(event.target).closest('[' + footnoteAttribute + ']').length === 0) {
        clearTimeout(footnoteTimer);
        footnoteTimer = setTimeout(hideAll, popoverTimeout);
      } else {
        clearTimeout(footnoteTimer);
      }
    }
    function getFootnote(node) {
      return document.getElementById(node.hash.substring(1));
    }
    function getFootnoteContent() {
      if (touchAvailable()) {
        return $(getFootnote(this)).html();
      }
      var footnote = $(
        '<div class="footnote-popover">' +
        '  <button type="button" class="close footnote-close-button" aria-label="Close">' +
        '    <span aria-hidden="true">×</span>' +
        '  </button>' +
        '  <div class="footnote-body" />' +
        '</div>'
      );
      $('.footnote-close-button', footnote).click(hideAll);
      $('.footnote-body', footnote).append($(getFootnote(this)).html());
      return footnote;
    }
    var options = {
      content: getFootnoteContent,
      html: true,
      placement: 'auto',
      trigger: 'manual',
    };
    footnoteModal.modal({
      show: false,
    });
    $('.modal-body #link a', footnoteModal).click(function(event) {
      footnoteModal.modal('hide');
      $('.footnotes')[0].scrollIntoView();
      event.preventDefault();
    })
    footnotes
      .popover(options)
      .on('shown.bs.popover', function(event) {
        if (touchAvailable()) return;
        $(this)
          .attr(footnoteAttribute, true)
          .next().attr(footnoteAttribute, true);
        $(parentSelector).mousemove(mouseMove);
      })
      .on('hide.bs.popover', function() {
        if (touchAvailable()) return;
        $(this).removeAttr(footnoteAttribute);
      })
      .click(function(event) {
        if (touchAvailable()) {
          event.preventDefault();
          event.stopImmediatePropagation();
          $('.modal-body #footnote', footnoteModal).html(getFootnoteContent.call(this))
          footnoteModal.modal('show');
        }
        $(event.target).closest('a').popover('hide');
      })
      .mouseenter(function(event) {
        if (touchAvailable()) return;
        var target = $(event.target).closest('a');
        if(target.attr(footnoteAttribute)) {
          return;
        }
        footnotes.removeAttr(footnoteAttribute);
        target.attr(footnoteAttribute, true);
        footnotes.each(function(i, footnote) {
          if($(footnote).attr(footnoteAttribute)) {
            return;
          }
          $(footnote).popover('hide')
        });
        target.popover('show');
        $(parentSelector)
          .off('click', hideAll)
          .click(hideAll);
      });
  }
  window.initFootnotes = initFootnotes;
});
