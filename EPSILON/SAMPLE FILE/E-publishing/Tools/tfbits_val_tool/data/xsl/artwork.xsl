<?xml version="1.0" encoding="UTF-8"?>
<!--Sion 5th November 2011-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="/book">
		<ul>
			<xsl:for-each select=".//graphic|.//inline-graphic">
				<xsl:variable name="img">
					<xsl:choose>
						<xsl:when test="name()='inline-graphic'">
							<li xmlns:xlink="http://www.w3.org/1999/xlink">
								<xsl:value-of select="@xlink:href"/><xsl:if test="@mime-subtype">
									<xsl:text>.</xsl:text>
									<xsl:value-of select="@mime-subtype"/>
								</xsl:if>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li xmlns:xlink="http://www.w3.org/1999/xlink">
								<xsl:value-of select="@xlink:href"/>
								<xsl:if test="@mime-subtype">
									<xsl:text>.</xsl:text>
									<xsl:value-of select="@mime-subtype"/>
								</xsl:if>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:apply-templates select="$img/node()"/>
			</xsl:for-each>
		</ul>
	</xsl:template>
	<xsl:template match="*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
</xsl:stylesheet>
