<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" />

<xsl:variable name="siteUrl" select="/document/@siteUrl" />

<xsl:template match="/">
<html>
<head>
    <title><xsl:value-of select="/document/content/@title" /></title>

    <base>
        <xsl:attribute name="href"><xsl:value-of select="$siteUrl" /></xsl:attribute>
    </base>

    <link rel="stylesheet" href="content/treeview/jquery.treeview.css" />
    <link rel="stylesheet" href="content/tabs/jquery.tabs.css" type="text/css" media="print, projection, screen" />
    <link rel="stylesheet" href="content/css/style.css" type="text/css" />

    <script src="content/js/jquery.js" type="text/javascript"></script>
    <script src="content/js/jquery.cookie.js" type="text/javascript"></script>
    <script src="content/treeview/jquery.treeview.js" type="text/javascript"></script>
    <script src="content/tabs/jquery.history_remote.pack.js" type="text/javascript"></script>
    <script src="content/tabs/jquery.tabs.pack.js" type="text/javascript"></script>

    <script type="text/javascript">
    </script>
</head>
<body>
<div class="container">

<h1>My Website</h1>

<xsl:call-template name="nav" />
<xsl:call-template name="subnav" />

<div id="content">
<xsl:apply-templates select="/document" />
</div>

</div>
</body>
</html>

</xsl:template>

<xsl:template name="nav">
  <div id="nav">
    <ul>
      <xsl:for-each select="/document/sitemap/node">
        <li>
          <xsl:attribute name="class">
            <xsl:value-of select="@name" />
            <xsl:if test="position() = 1"> first</xsl:if>
            <xsl:if test="position() = last()"> last</xsl:if>
            <xsl:if test="@active = 'true'"> active</xsl:if>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="@url" />
            </xsl:attribute>
            <span><xsl:value-of select="@title" /></span>
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </div>
</xsl:template>

<xsl:template name="subnav">
  <xsl:if test="count(/document/sitemap/node[@active='true']/node) > 0">
    <div id="subnav">
      <ul>
      <xsl:for-each select="/document/sitemap/node[@active='true']/node">
        <li>
          <xsl:attribute name="class">
            <xsl:value-of select="@name" />
            <xsl:if test="position() = 1"> first</xsl:if>
            <xsl:if test="position() = last()"> last</xsl:if>
            <xsl:if test="@active = 'true'"> active</xsl:if>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="@url" />
            </xsl:attribute>
            <span><xsl:value-of select="@title" /></span>
          </a>
        </li>
      </xsl:for-each>
      </ul>
    </div>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
