<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_311" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">311</xsl:variable>
		<xsl:variable name="rule_name">Check for missing chapter DOIs.</xsl:variable>
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
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<!--
				-->
				<xsl:for-each select="//book-part[@book-part-type = 'chapter']">
					<xsl:choose>
						<!--<book-part book-part-type="chapter" id="chapter5">
							<book-part-meta>
								<book-part-id book-part-id-type="doi">10.4324/9781315652566-5</book-part-id>-->
								<!--<xsl:when test="./book-part-meta/book-part-id[@pub-id-type = 'doi']"/>-->
						<xsl:when test="./book-part-meta/book-part-id[@book-part-id-type = 'doi']"/>
						<xsl:otherwise>
							<hit>
								<title>
									<xsl:value-of select="./book-part-meta/title-group/title"/>
								</title>
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
							</hit>
						</xsl:otherwise>
					</xsl:choose>
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
								<xsl:text>Missing chapter DOI in chapter </xsl:text>
								<xsl:if test="not(./title = '')">
									<xsl:text>"</xsl:text>
									<xsl:value-of select="./title"/>
									<xsl:text>" </xsl:text>
								</xsl:if>
								<xsl:text>(</xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
								<xsl:text>).</xsl:text>
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