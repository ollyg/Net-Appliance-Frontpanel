<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        <portGroup type="cevPortNIC100" x="0" y="0" xStep="0" yStep="0"
        width="6" height="2" countDirection="down"/>
    -->
    <xsl:template match="portGroup" name="pg">
        <xsl:param name="w">0</xsl:param>
        <xsl:param name="h">0</xsl:param>
        <xsl:variable name="rotate">
            <xsl:value-of select="@rotate"/>
            <xsl:if test="not(@rotate)">0</xsl:if>
        </xsl:variable>

        <!--  stop when we hit max w and h -->
        <xsl:if test="$w &lt; @width and $h &lt; @height">
            <xsl:element name="port">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
                <xsl:attribute name="rotate">
                    <xsl:if test="@autoInvert = 'false' or @autoInvert = 0">
                        <xsl:value-of select="$rotate"/>
                    </xsl:if>
                    <xsl:if test="not(@autoInvert = 'false' or @autoInvert = 0)">
                        <xsl:value-of select="$rotate + ((($h + @height + 1) mod 2) * 180)"/>
                    </xsl:if>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="@x + (@xStep * $w)"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="@y + (@yStep * $h)"/>
                </xsl:attribute>
            </xsl:element>

            <xsl:if test="@countDirection = 'down'">
                <xsl:if test="$h = (@height - 1)">
                    <xsl:call-template name="pg">
                        <xsl:with-param name="w" select="$w + 1"/>
                        <xsl:with-param name="h" select="0"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="not($h = (@height - 1))">
                    <xsl:call-template name="pg">
                        <xsl:with-param name="w" select="$w"/>
                        <xsl:with-param name="h" select="$h + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>

            <xsl:if test="@countDirection = 'across'">
                <xsl:if test="$w = (@width - 1)">
                    <xsl:call-template name="pg">
                        <xsl:with-param name="w" select="0"/>
                        <xsl:with-param name="h" select="$h + 1"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="not($w = (@width - 1))">
                    <xsl:call-template name="pg">
                        <xsl:with-param name="w" select="$w + 1"/>
                        <xsl:with-param name="h" select="$h"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--
        <containerGroup type="cevContainer10GigBasePort" x="0" y="0" xStep="0" yStep="0"
        height="1" width="4"/>
    -->
    <xsl:template match="containerGroup" name="cg">
        <xsl:param name="w">0</xsl:param>
        <xsl:param name="h">0</xsl:param>
        <xsl:variable name="rotate">
            <xsl:value-of select="@rotate"/>
            <xsl:if test="not(@rotate)">0</xsl:if>
        </xsl:variable>
        
        <!--  stop when we hit max w and h -->
        <xsl:if test="$w &lt; @width and $h &lt; @height">
            <xsl:element name="container">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
                <xsl:attribute name="rotate">
                    <xsl:value-of select="$rotate"/>
                </xsl:attribute>
                <xsl:attribute name="x">
                    <xsl:value-of select="@x + (@xStep * $w)"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                    <xsl:value-of select="@y + (@yStep * $h)"/>
                </xsl:attribute>
            </xsl:element>

            <xsl:if test="@countDirection = 'down'">
                <xsl:if test="$h = (@height - 1)">
                    <xsl:call-template name="cg">
                        <xsl:with-param name="w" select="$w + 1"/>
                        <xsl:with-param name="h" select="0"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="not($h = (@height - 1))">
                    <xsl:call-template name="cg">
                        <xsl:with-param name="w" select="$w"/>
                        <xsl:with-param name="h" select="$h + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>

            <xsl:if test="@countDirection = 'across'">
                <xsl:if test="$w = (@width - 1)">
                    <xsl:call-template name="cg">
                        <xsl:with-param name="w" select="0"/>
                        <xsl:with-param name="h" select="$h + 1"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="not($w = (@width - 1))">
                    <xsl:call-template name="cg">
                        <xsl:with-param name="w" select="$w + 1"/>
                        <xsl:with-param name="h" select="$h"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
