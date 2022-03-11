<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_205" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">205</xsl:variable>
		<xsl:variable name="rule_name">Check for endorsements.</xsl:variable>
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
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="/book/front-matter/front-matter-part/book-part-meta/title-group/title/text()[matches(., '(endorsement|praise for)', 'i')]">
						<hit>
							<text>
								<xsl:text>title matches "endorsement", "praise for": </xsl:text>
								<xsl:value-of select="."/>
								<xsl:text>", new model is /book/book-meta/notes notes-type="endorsements"</xsl:text>
							</text>
							<location>
								<xsl:attribute name="type">xpath</xsl:attribute>
								<xsl:for-each select="ancestor::*">
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:for-each>
								<xsl:text>/</xsl:text>
								<xsl:value-of select="name()"/>
							</location>
						</hit>
				</xsl:for-each>
				<xsl:for-each select="/book/front-matter/notes[@notes-type='endorsements']">
					<hit>
						<text>
							<xsl:text>notes notes-type="endorsements" nested in front-matter, new model is /book/book-meta/notes notes-type="endorsements" </xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>"</xsl:text>
						</text>
						<location>
							<xsl:attribute name="type">xpath</xsl:attribute>
							<xsl:for-each select="ancestor::*">
								<xsl:text>/</xsl:text>
								<xsl:value-of select="name()"/>
							</xsl:for-each>
							<xsl:text>/</xsl:text>
							<xsl:value-of select="name()"/>
						</location>
					</hit>
				</xsl:for-each>
				<xsl:for-each select="/book/front-matter/front-matter-part[@book-part-type='endorsements']">
					<hit>
						<text>
							<xsl:text>front-matter-part book-part-type="endorsements" nested in front-matter, new model is /book/book-meta/notes notes-type="endorsements" </xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>"</xsl:text>
						</text>
						<location>
							<xsl:attribute name="type">xpath</xsl:attribute>
							<xsl:for-each select="ancestor::*">
								<xsl:text>/</xsl:text>
								<xsl:value-of select="name()"/>
							</xsl:for-each>
							<xsl:text>/</xsl:text>
							<xsl:value-of select="name()"/>
						</location>
					</hit>
				</xsl:for-each>
				
					<!--
					-->
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
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found incorrectly-tagged endorsements </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
								<xsl:if test="./title">
									<xsl:text> (title: "</xsl:text>
									<xsl:value-of select="./title"/>
									<xsl:text>")</xsl:text>
								</xsl:if>
								<xsl:if test="./text">
									<xsl:text> (</xsl:text>
									<xsl:value-of select="./text"/>
									<xsl:text>)</xsl:text>
								</xsl:if>
								<xsl:text>.</xsl:text>
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
