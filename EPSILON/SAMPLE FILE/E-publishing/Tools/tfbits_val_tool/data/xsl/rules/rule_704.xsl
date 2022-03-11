<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_704" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">704</xsl:variable>
		<xsl:variable name="rule_name">Check endnote structure.</xsl:variable>
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
		<!-- find citations to fn elements where the fn is not in the book-part or top-level front or back matter section -->
		<xsl:variable name="invalid_fn">
			<xml>
				<xsl:for-each select="//xref[@ref-type='fn' and @rid]">
					<xsl:choose>
						<xsl:when test="@rid = ancestor::table-wrap[1]/table-wrap-foot/fn-group/fn/@id"/>
						<xsl:when test="@rid = ancestor::boxed-text[1]//fn-group/fn/@id"/>
						<xsl:when test="@rid = ancestor::book-part[1]/back/fn-group/fn/@id"/>
						<xsl:when test="@rid = ancestor::*[self::foreword or self::preface or self::front-matter-part or self::dedication][1][parent::front-matter[parent::book]]/back/fn-group/fn/@id"/>
						<xsl:when test="@rid = ancestor::*[self::ack or self::glossary][1][parent::front-matter[parent::book]]/fn-group/fn/@id"/>
						<xsl:when test="@rid = ancestor::*[self::book-app or self::book-part or self::dedication][1][parent::book-back]/back/fn-group/fn/@id"/>
						<xsl:when test="@rid = ancestor::*[self::ack or self::glossary][1][parent::book-back]/fn-group/fn/@id"/>
						<xsl:otherwise>
							<xsl:variable name="id" select="@rid"/>
							<fail>
								<id>
									<xsl:value-of select="$id"/>
								</id>
								<fn-location>
									<xsl:for-each select="//fn[@id = $id]">
										<xsl:for-each select="ancestor::*">
											<xsl:text>/</xsl:text>
											<xsl:value-of select="name()"/>
										</xsl:for-each>
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>
								</fn-location>
							</fail>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="count($invalid_fn//fail) = 0">
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class">pass</xsl:attribute>
							<xsl:text>pass</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$invalid_fn//fail">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found citation to a note where the cited &lt;fn&gt; in not located in the same book-part or top-level front or back matter section as the citation: fn with</xsl:text>
								<xsl:text> id="</xsl:text>
								<xsl:value-of select="./id"/>
								<xsl:text>" </xsl:text>
								<xsl:choose>
									<xsl:when test="./fn-location = ''">cannot be found in document.</xsl:when>
									<xsl:otherwise>located at <xsl:value-of select="./fn-location"/></xsl:otherwise>
								</xsl:choose>
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
