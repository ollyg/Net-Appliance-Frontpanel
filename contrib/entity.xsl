<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:template match="/">
        <stack>
            <!-- peek at device for which this doc shows status -->
            <xsl:apply-templates select="//device//chassis"/>
        </stack>
    </xsl:template>

    <xsl:template match="device//chassis">
        <xsl:variable name="type" select="@type"/>
        <chassis>
            <!-- jump to matching chassis spec for this device -->
            <xsl:apply-templates select="//classes/chassis[@type = $type]"/>
            <!-- process kids of this node -->
            <!-- pass our ID which is first part of class section --> 
            <xsl:apply-templates select="*">
                <xsl:with-param name="rootname" select="local-name()"/>
                <xsl:with-param name="roottype" select="@type"/>
            </xsl:apply-templates>
        </chassis>
    </xsl:template>

    <xsl:template match="device//chassis//container">
        <xsl:param name="rootname"/>
        <xsl:param name="roottype"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="mypos"
            select="1+count(preceding-sibling::container[@type = $type])"/>
        <xsl:variable name="classofme"
            select="//classes/*[local-name() = $rootname and @type = $roottype]/container[@type = $type]"/>
        
        <!-- process kids of this node -->
        <!-- pass on the root's ID we received, and our own to complete the class section name -->
        <xsl:apply-templates select="*">
            <xsl:with-param name="rootname" select="$rootname"/>
            <xsl:with-param name="roottype" select="$roottype"/>
            <xsl:with-param name="parentname" select="local-name()"/>
            <xsl:with-param name="parenttype" select="$type"/>
            <xsl:with-param name="parentpos" select="$mypos"/>
        </xsl:apply-templates>
        
        <!-- try to show an image for this container if there are no children -->
        <xsl:if test="not(count(*)) and boolean(//classes//port-image[@type = $type])">
            <xsl:variable name="rotate">
                <xsl:value-of select="$classofme[$mypos]/@rotate"/>
                <xsl:if test="not($classofme[$mypos]/@rotate)">0</xsl:if>
            </xsl:variable>
            <port>
                <name><xsl:value-of select="@name"/></name>
                <x><xsl:value-of select="$classofme[$mypos]/@x"/></x>
                <y><xsl:value-of select="$classofme[$mypos]/@y"/></y>
                <rotate><xsl:value-of select="$rotate"/></rotate>
                <dummy><xsl:text>yes</xsl:text></dummy>

                <!-- next find the type to use, which has fallbacks, namely:
                    root/type
                    type
                    (where root is 'chassis' or 'module') -->
                
                <xsl:variable name="root_type" select="concat($roottype, '_', $type)"/>
                
                <xsl:choose>
                    <xsl:when test="boolean(//classes//port-image[@type = $root_type])">
                        <type><xsl:value-of select="$root_type"/></type>
                    </xsl:when>
                    <xsl:otherwise>
                        <type><xsl:value-of select="@type"/></type>
                    </xsl:otherwise>
                </xsl:choose>
            </port>
        </xsl:if>
    </xsl:template>

    <xsl:template match="device//chassis//module">
        <xsl:param name="rootname"/>
        <xsl:param name="roottype"/>
        <xsl:param name="parentname"/>
        <xsl:param name="parentpos"/>
        <xsl:variable name="type" select="@type"/>
        <!-- class is containing node from the classes section -->
        <xsl:variable name="class"
                select="//classes/*[local-name() = $rootname and @type = $roottype]/*[local-name() = $parentname]"/>
        <xsl:variable name="rotate">
            <xsl:value-of select="$class[$parentpos]/@rotate"/>
            <xsl:if test="not($class[$parentpos]/@rotate)">0</xsl:if>
        </xsl:variable>

        <xsl:choose>
            <!-- this module has a matching class -->
            <xsl:when test="//classes/module[@type = $type]">
                <xsl:text disable-output-escaping="yes">&lt;module&gt;</xsl:text>
                
                <!-- jump to matching module spec for this device -->
                <xsl:apply-templates select="//classes/module[@type = $type]"/>
                
                <!--  grab module's X and Y coordinates from containing node -->
                <x><xsl:value-of select="$class[$parentpos]/@x"/></x>
                <y><xsl:value-of select="$class[$parentpos]/@y"/></y>
                
                <rotate><xsl:value-of select="$rotate"/></rotate>
                
                <!-- pass on the root's ID we received, and our own to complete the class section name -->
                <xsl:apply-templates select="*">
                    <xsl:with-param name="rootname" select="local-name()"/>
                    <xsl:with-param name="roottype" select="@type"/>
                </xsl:apply-templates>
                
                <xsl:text disable-output-escaping="yes">&lt;/module&gt;</xsl:text>
            </xsl:when>

            <!-- else this node is a dummy, process kids of this node -->
            <!-- treat as a no-op by not passing our ID -->
            <xsl:otherwise>
                <xsl:apply-templates select="*">
                    <xsl:with-param name="rootname" select="$rootname"/>
                    <xsl:with-param name="roottype" select="$roottype"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="device//chassis//port">
        <xsl:param name="rootname"/>
        <xsl:param name="roottype"/>
        <xsl:param name="parentname"/>
        <xsl:param name="parenttype"/>
        <xsl:param name="parentpos"/>

        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="mypos"
                select="1+count(preceding-sibling::port[@type = $type])"/>
        <!-- class is containing node from the classes section - there are two choices depending on where the port is -->
        <xsl:variable name="classofparent"
                select="//classes/*[local-name() = $rootname and @type = $roottype]/*[local-name() = $parentname]"/>
        <xsl:variable name="classofme"
                select="//classes/*[local-name() = $rootname and @type = $roottype]/port[@type = $type]"/>
        
        <!-- this port has a matching class -->
        <xsl:if test="(boolean($parentname) and boolean($classofparent[$parentpos])) 
                        or (not(boolean($parentname)) and boolean($classofme[$mypos]))">
        <port>
            <name><xsl:value-of select="@name"/></name>
            
            <xsl:choose>
                <!-- grab port's rotation, X and Y coordinates from containing node -->
                <xsl:when test="boolean($parentname)">
                    <xsl:variable name="rotate">
                        <xsl:value-of select="$classofparent[$parentpos]/@rotate"/>
                        <xsl:if test="not($classofparent[$parentpos]/@rotate)">0</xsl:if>
                    </xsl:variable>
                    <x><xsl:value-of select="$classofparent[$parentpos]/@x"/></x>
                    <y><xsl:value-of select="$classofparent[$parentpos]/@y"/></y>
                    <rotate><xsl:value-of select="$rotate"/></rotate>
                </xsl:when>

                <!-- else use our own rotate, X, Y -->
                <xsl:otherwise>
                    <xsl:variable name="rotate">
                        <xsl:value-of select="$classofme[$mypos]/@rotate"/>
                        <xsl:if test="not($classofme[$mypos]/@rotate)">0</xsl:if>
                    </xsl:variable>
                    <x><xsl:value-of select="$classofme[$mypos]/@x"/></x>
                    <y><xsl:value-of select="$classofme[$mypos]/@y"/></y>
                    <rotate><xsl:value-of select="$rotate"/></rotate>
                </xsl:otherwise>
            </xsl:choose>

            <!-- next find the type to use, which has various fallbacks, namely:
                     root/parent/type
                     parent/type
                     root/type
                     type
            (where root is 'chassis' or 'module', and parent is 'container') -->

            <xsl:variable name="root_parent_type" select="concat($roottype, '_', $parenttype, '_', $type)"/>
            <xsl:variable name="parent_type" select="concat($parenttype, '_', $type)"/>
            <xsl:variable name="root_type" select="concat($roottype, '_', $type)"/>
            
            <xsl:choose>
                <xsl:when test="boolean(//classes//port-image[@type = $root_parent_type])">
                    <type><xsl:value-of select="$root_parent_type"/></type>
                </xsl:when>
                <xsl:when test="boolean(//classes//port-image[@type = $parent_type])">
                    <type><xsl:value-of select="$parent_type"/></type>
                </xsl:when>
                <xsl:when test="boolean(//classes//port-image[@type = $root_type])">
                    <type><xsl:value-of select="$root_type"/></type>
                </xsl:when>
                <xsl:otherwise>
                    <type><xsl:value-of select="@type"/></type>
                </xsl:otherwise>
            </xsl:choose>

        </port>
        </xsl:if>
    </xsl:template>

<!--  devices above the line -->
<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
<!--   spec below the line   -->
    
    <xsl:template match="classes/chassis">
        <image><xsl:value-of select="@image"/></image>
    </xsl:template>
    
    <xsl:template match="classes/module">
        <image><xsl:value-of select="@image"/></image>
    </xsl:template>
    
</xsl:stylesheet>
