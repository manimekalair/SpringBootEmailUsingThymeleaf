<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_404" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">404</xsl:variable>
		<xsl:variable name="rule_name">Check page start &lt;target&gt; id format.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>
		<!--
		
		-->
		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:element name="td">
				<xsl:element name="span">
					<xsl:attribute name="class">rule</xsl:attribute>
					<xsl:text>Rule </xsl:text>
					<xsl:value-of select="$rule_number"/>
				</xsl:element>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="$rule_name"/>
			</xsl:element>
		</xsl:variable>
		<!--
		
		-->
		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!--
		
		-->
		<!-- build list of errors -->
		<xsl:variable name="hit_list">
			<xml>
				<!--<xsl:for-each select="//xref[@ref-type='page' and @id]">-->
				<!-- Sion simplified -->
				<xsl:for-each select="//target[@target-type='page' and @id][not(matches(@id, '^page_(\d+|[ivxlcm]+)$'))]">
					<!-- <xsl:choose>
						<!-\- find page xref ids that do not start with 'page_' -\->
						<xsl:when test="not(starts-with(./@id,'page_'))">
							<hit type="prefix">
								<id>
									<xsl:value-of select="./@id"/>
								</id>
							</hit>
						</xsl:when>
						<xsl:otherwise>
							<!-\- grab page number part of id -\->
							<xsl:variable name="page_no" select="replace(./@id,'page_','')"/>
							<xsl:choose>
								<!-\- throw away arabic page numbers -\->
								<xsl:when test="replace($page_no,'\d+','') = ''"/>
								<!-\- throw away roman page numbers -\->
								<xsl:when test="replace($page_no,'[ivxlcm]+','') = ''"/>
								<!-\- anything left is an invalid page number -\->
								<xsl:otherwise>
-->									<hit>
										<id>
											<xsl:value-of select="./@id"/>
										</id>
									</hit>
<!--								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
-->				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="not($hit_list//hit)">
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class">pass</xsl:attribute>
							<xsl:text>pass</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$hit_list//hit">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Page start marker had invalid id="</xsl:text>
								<xsl:value-of select="./id"/>
								<xsl:text>".</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--
		
		-->
		<!-- DISPLAY RESULTS -->
		<xsl:copy-of select="$result"/>
		<!--
		
		-->
	</xsl:template>
</xsl:stylesheet>
