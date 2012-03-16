<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" />

<xsl:template match="/page">

    <form method="post" action="">
    <xsl:for-each select="actions/action">
        <input type="submit">
            <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>
            <xsl:attribute name="value"><xsl:value-of select="@title" /></xsl:attribute>
        </input>
    </xsl:for-each>

    <hr />

    <xsl:for-each select="elements/element">
        <div>
            <xsl:value-of select="@title" />:
            <xsl:copy-of select="node()" />
        </div>
    </xsl:for-each>
    </form>

</xsl:template>

</xsl:stylesheet>