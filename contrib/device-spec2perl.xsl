<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="stack">
        [
            <xsl:apply-templates select="*"/>
        ],
    </xsl:template>

    <xsl:template match="chassis|module">
        {
        <xsl:apply-templates select="*[local-name() = 'image']"/>
        <xsl:apply-templates select="*[local-name() = 'x']"/>
        <xsl:apply-templates select="*[local-name() = 'y']"/>
        <xsl:apply-templates select="*[local-name() = 'rotate']"/>
        modules <xsl:text disable-output-escaping="yes">=&gt;</xsl:text> [
            <xsl:apply-templates select="*[local-name() = 'module']"/>
        ],
        ports <xsl:text disable-output-escaping="yes">=&gt;</xsl:text> [
            <xsl:apply-templates select="*[local-name() = 'port']"/>
        ],
        },
    </xsl:template>
    
    <xsl:template match="port">
        {
            <xsl:apply-templates select="*"/>
        },
    </xsl:template>
    
    <xsl:template match="name|image|type|x|y|rotate|dummy">
        '<xsl:value-of select="local-name()"/>' <xsl:text disable-output-escaping="yes">=&gt;</xsl:text>
            '<xsl:value-of select="text()"/>',
    </xsl:template>
    
</xsl:stylesheet>
