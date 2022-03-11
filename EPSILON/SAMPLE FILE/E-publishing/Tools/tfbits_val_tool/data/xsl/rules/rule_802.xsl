<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_802" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">802</xsl:variable>
		<xsl:variable name="rule_name">Check &lt;lpage&gt;.</xsl:variable>
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
				<!--  -->
				<xsl:for-each select="//ref">
					<xsl:variable name="ref" select="."/>
					<xsl:variable name="location">
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
					</xsl:variable>
					<!--
					-->
					<!-- test whether the number of lpage elements is greater than fpage elements -->
					<xsl:if test="count(.//lpage) gt count(.//fpage)">
						<hit type="mismatch">
							<ref>
								<xsl:value-of select="$ref"/>
							</ref>
							<fpage_count>
								<xsl:value-of select="count(.//fpage)"/>
							</fpage_count>
							<lpage_count>
								<xsl:value-of select="count(.//lpage)"/>
							</lpage_count>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test if lpage value is greater than fpage value -->
					<xsl:for-each select=".//lpage">
						<!--
						-->
						<!-- set variable to lpage value -->
						<xsl:variable name="lpage_value" select="number(.)"/>
						<!--
						-->
						<!-- set variable to first preceding fpage value -->
						<xsl:variable name="fpage_value" select="preceding::fpage[1]/number(.)"/>
						<!--
						-->
						<!-- if lpage is less than fpage, return hit details -->
						<xsl:if test="$lpage_value lt $fpage_value">
							<hit type="invalid_lpage">
								<ref>
									<xsl:value-of select="$ref"/>
								</ref>
								<fpage>
									<xsl:value-of select="$fpage_value"/>
								</fpage>
								<lpage>
									<xsl:value-of select="$lpage_value"/>
								</lpage>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:if>
					</xsl:for-each>
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
								<xsl:choose>
									<!--
									-->
									<!-- mismatch report -->
									<xsl:when test="./@type = 'mismatch'">
										<xsl:text>Number of lpage elements (</xsl:text>
										<xsl:value-of select="./lpage_count"/>
										<xsl:text>) does not match number of fpage elements (</xsl:text>
										<xsl:value-of select="./fpage_count"/>
										<xsl:text>) – </xsl:text>
										<xsl:if test="./location/@type = 'xpath'">
											<xsl:text>at: </xsl:text>
										</xsl:if>
										<xsl:if test="./location/@type = 'element'">
											<xsl:text>in: </xsl:text>
										</xsl:if>
										<xsl:value-of select="./location"/>
										<xsl:text>. ("</xsl:text>
										<xsl:value-of select="./ref"/>
										<xsl:text>")</xsl:text>
									</xsl:when>
									<!--
									-->
									<!-- invalid lpage report -->
									<xsl:when test="./@type = 'invalid_lpage'">
										<xsl:text>Number in fpage (</xsl:text>
										<xsl:value-of select="./fpage"/>
										<xsl:text>) is greater than in lpage (</xsl:text>
										<xsl:value-of select="./lpage"/>
										<xsl:text>) – </xsl:text>
										<xsl:if test="./location/@type = 'xpath'">
											<xsl:text>at: </xsl:text>
										</xsl:if>
										<xsl:if test="./location/@type = 'element'">
											<xsl:text>in: </xsl:text>
										</xsl:if>
										<xsl:value-of select="./location"/>
										<xsl:text>. ("</xsl:text>
										<xsl:value-of select="./ref"/>
										<xsl:text>")</xsl:text>
									</xsl:when>
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
