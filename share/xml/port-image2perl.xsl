<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="text"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="classes">
        {
            <xsl:apply-templates select="*"/>
        }
    </xsl:template>
    
    <xsl:template match="port-image">
        '<xsl:value-of select="@type"/>' <xsl:text disable-output-escaping="yes">=&gt;</xsl:text>
        {
            <xsl:apply-templates select="*"/>
        },
    </xsl:template>
    
    <xsl:template match="up|down|empty">
        '<xsl:value-of select="local-name()"/>' <xsl:text disable-output-escaping="yes">=&gt;</xsl:text>
            '<xsl:value-of select="text()"/>',
    </xsl:template>

</xsl:stylesheet>
