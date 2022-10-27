<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math xd tei"
    version="3.0">
    
    <xsl:param name="heading" as="xs:boolean" select="true()"/>
    <xsl:param name="documentID" as="xs:string" select="/tei:TEI/@xml:id"/>
    
    <xsl:output indent="true"/>
    
    <xsl:mode on-no-match="shallow-skip" use-accumulators="#all"/>
    <xsl:mode name="html" on-no-match="text-only-copy"/>
    
    <xsl:accumulator name="document-ids" initial-value="()" as="xs:string*">
        <xsl:accumulator-rule match="tei:div[@type eq 'document']" select="($value, @n)" phase="end"/>
    </xsl:accumulator>
    
    <xsl:template match="tei:TEI">
        <div id="toc">
            <div class="hsg-toc-sidebar">
                <div class="toc-inner">
                    <!-- Create header, if there is one -->
                    <xsl:apply-templates select="(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='volume'])[1][$heading]"></xsl:apply-templates>
                    <ul>
                        <xsl:apply-templates select="tei:text"/>
                    </ul>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'volume']">
        <div>
            <h2><xsl:apply-templates mode="html"/></h2>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:div[@xml:id]">
        <xsl:variable name="accDocs" as="xs:string*" select="accumulator-after('document-ids')"/>
        <xsl:variable name="prevDocs" as="xs:string*" select="accumulator-before('document-ids')"/>
        <xsl:variable name="docs" as="xs:string*" select="$accDocs[not(. = $prevDocs)]"/>
        <li data-tei-id="{@xml:id}">
            <span>
                <a href="/historicaldocument/{$documentID}/{@xml:id}">
                    <xsl:apply-templates select="tei:head" mode="html"/>
                </a>
                <xsl:value-of select="(
                    ' (Document' ||
                    's'[count($docs) gt 1] ||
                    ' ' ||
                    $docs[1] ||
                    ' - '[count($docs) gt 1] ||
                    $docs[last()][count($docs) gt 1] ||
                    ')'
                )[exists($docs)]"/>
            </span>
            <xsl:where-populated>
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </xsl:where-populated>
        </li>
    </xsl:template>
    
    <xsl:template match="tei:div[@xml:id eq 'toc']" priority="2"/>
    
    <xsl:template match="tei:front">
        <xsl:where-populated>
            <li>
                <xsl:on-non-empty>
                    <span>Front Matter</span>
                </xsl:on-non-empty>
                <xsl:where-populated>
                    <ul>
                        <xsl:apply-templates/>
                    </ul>
                </xsl:where-populated>
            </li>
        </xsl:where-populated>
    </xsl:template>
    
    <xsl:template match="tei:head/tei:note" mode="html"/>
    
    <xsl:template match="tei:lb" mode="html">
        <br/>
    </xsl:template>
    
</xsl:stylesheet>