<xsl:stylesheet 
    exclude-result-prefixes="#all" 
    version="3.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 15, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> Tomos Hillman (TFJH), Evolved Binary Ltd.</xd:p>
            <xd:p>This stylesheet processes xhtml fragments for inclusion on hsg pages.  It cleans up unwanted nodes, and adds useful ones.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:mode on-no-match="shallow-copy" on-multiple-match="use-last" warning-on-multiple-match="no"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>The summary mode is used to turn text into a set on in-line elements for use on summary lines.</xd:p>
            <xd:p>Most elements in the summary should be skipped</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:mode name="summary" on-no-match="shallow-skip" on-multiple-match="use-last" warning-on-multiple-match="no"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>We want to keep text nodes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text()" mode="summary">
        <xsl:copy/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Keep some elements in the summary</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xhtml:em|xhtml:strong|xhtml:a" mode="summary">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Some elements should be skipped entirely (e.g. figures).  We replace them here with a single whitespace to avoid text running together.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xhtml:figure|xhtml:br|xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6|xhtml:img" mode="summary">
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Italics should be replaced with emphasis tags</xd:p>
            <xd:p><xd:b>Modes:</xd:b> #unnamed, summary</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xhtml:i" mode="#unnamed summary">
        <em xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="#current" select="@*, node()"/>
        </em>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Bold should be replaced with strong tags</xd:p>
            <xd:p><xd:b>Modes:</xd:b> #unnamed, summary</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xhtml:b" mode="#unnamed summary">
        <strong xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates mode="#current" select="@*, node()"/>
        </strong>
    </xsl:template>
    
    
</xsl:stylesheet>
