<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_803" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">803</xsl:variable>
		<xsl:variable name="rule_name">Check for styles.</xsl:variable>
		<xsl:variable name="error_type">warning</xsl:variable>
		
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
		<!-- build list of ref elements -->
		<xsl:variable name="ref_elements">
			<xml>
				<!--  -->
				<xsl:for-each select="//ref//*">
					<element>
						<xsl:copy-of select="." copy-namespaces="no"/>
						<location>
							<xsl:choose>
								<xsl:when test="./ancestor-or-self::*[@id][1]">
									<xsl:attribute name="type">element</xsl:attribute>
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="name(./ancestor-or-self::*[@id][1])"/>
									<xsl:text> id="</xsl:text>
									<xsl:value-of select="./ancestor-or-self::*[@id][1]/@id"/>
									<xsl:text>"&gt;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="type">xpath</xsl:attribute>
									<xsl:for-each select="ancestor::*">
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</location>
					</element>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="$ref_elements//element/*[1]">
					<!-- test if element is all italic -->
					<xsl:if test="./italic and count(child::node()) = 1">
						<hit type="italic">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="following-sibling::location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all italic and includes a page marker xref -->
					<xsl:if test="./italic and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="italic">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="following-sibling::location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all bold -->
					<xsl:if test="./bold and count(child::node()) = 1">
						<hit type="bold">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="following-sibling::location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all bold and includes a page marker xref -->
					<xsl:if test="./bold and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="bold">
							<text>
								<xsl:value-of select="."/>
							</text>
							<name>
								<xsl:value-of select="name()"/>
							</name>
							<xsl:copy-of select="following-sibling::location"/>
						</hit>
					</xsl:if>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="count($hit_list//hit) = 0">
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
						<xsl:sort select="./@type" order="ascending"/>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found all </xsl:text>
								<xsl:value-of select="./@type"/>
								<xsl:text> in element &lt;</xsl:text>
								<xsl:value-of select="./name"/>
								<xsl:text>&gt; – "</xsl:text>
								<xsl:value-of select="./text"/>
								<xsl:text>". </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>At: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>In: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
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
