<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_424" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">424</xsl:variable>
		<xsl:variable name="rule_name">Check for labels in &lt;title&gt; for &lt;sec&gt; titles.</xsl:variable>
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
		<!-- find hits and create list -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="//sec/title/text()">
					<!--
					-->
					<!-- filter out exceptions and test on remainder -->
					<xsl:choose>
						<!--
						-->
						<!-- remove cases where title starts with a full point (e.g. if it starts with an ellipsis) -->
						<xsl:when test="starts-with(.,'.')"/>
						<!-- remove cases where title starts with a word made up of roman numeral characters -->
						<xsl:when test="matches(lower-case(.),'^(civic|civil|cm|di|did|dill|dim|i|icc|id|ill|lid|lil|livid|mic|mid|midi|mil|mild|mill|mimic|mix|mm|vim|vivid)(\.|:|\))')"/>
						<xsl:otherwise>
							<xsl:variable name="testStr">
								<xsl:value-of select="."/>
							</xsl:variable>
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
							<!-- test for words which may indicate label text -->
							<xsl:analyze-string select="lower-case(.)" regex="^(chapter|part|section|letter|entry)\s">
								<xsl:matching-substring>
									<hit>
										<found>
											<xsl:value-of select="."/>
										</found>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
							</xsl:analyze-string>
							<!--
					
							-->
							<!-- test for strings starting with three or fewer digits -->
							<xsl:analyze-string select="$testStr" regex="(^[0-9][0-9]?[0-9]?[^0-9]+)">
								<xsl:matching-substring>
									<hit>
										<found>
											<xsl:value-of select="."/>
										</found>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
							</xsl:analyze-string>
							<!--
							-->
							<!-- test for strings starting with digits, including full points -->
							<xsl:analyze-string select="$testStr" regex="(^[0-9]+\.[0-9]*.+)">
								<xsl:matching-substring>
									<hit>
										<found>
											<xsl:value-of select="."/>
										</found>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
							</xsl:analyze-string>
							<!--
							-->
							<!-- test for strings starting with roman numerals including full points, followed by space -->
							<xsl:analyze-string select="$testStr" regex="(^[IVXCMivxcm\.]+\s+[^A-Za-z]+[A-Za-z].+)">
								<xsl:matching-substring>
									<xsl:choose>
										<!--
										-->
										<!-- when string starts with word comprised of roman numerals, discard -->
										<xsl:when test="matches(lower-case($testStr),'^(civic|civil|cm|di|did|dill|dim|icc|id|ill|lid|lil|livid|mic|mid|midi|mil|mild|mill|mimic|mix|mm|vim|vivid)')"/>
										<!-- when string starts with i then a space, discard -->
										<xsl:when test="matches(lower-case($testStr),'^i\s+')"/>
										<xsl:otherwise>
											<hit>
												<found>
													<xsl:value-of select="."/>
												</found>
												<xsl:copy-of select="$location"/>
											</hit>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:matching-substring>
							</xsl:analyze-string>
							<!--
							-->
							<!-- test for strings starting with ( then digits or roman numerals, including full points, then ) -->
							<xsl:analyze-string select="$testStr" regex="(^\([IVXLCDMivxlcdm0-9\.]+\)[^A-Za-z]+[A-Za-z].+)">
								<xsl:matching-substring>
									<hit>
										<found>
											<xsl:value-of select="."/>
										</found>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
							</xsl:analyze-string>
							<!--
							-->
							<!-- test for strings starting with digits or roman numerals, including full points, then ), :, &#x2013;, or . -->
							<xsl:analyze-string select="$testStr" regex="(^[IVXLCDMivxlcdm0-9\.]+\s*)(&#x2013;|\)|:|\.)(\s*[^A-Za-z]+[A-Za-z].+)">
								<xsl:matching-substring>
									<hit>
										<found>
											<xsl:value-of select="."/>
										</found>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
							</xsl:analyze-string>
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
					<xsl:for-each select="$hit_list//hit[not(. = preceding-sibling::hit)]">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found title which may start with a label: "</xsl:text>
								<xsl:value-of select="./found"/>
								<xsl:text>" &#x2013; </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
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
