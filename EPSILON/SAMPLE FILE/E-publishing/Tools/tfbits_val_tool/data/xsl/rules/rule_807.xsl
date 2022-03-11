<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_807" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">807</xsl:variable>
		<xsl:variable name="rule_name">Check for untagged names.</xsl:variable>
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
				<!-- select all text that is not tagged in the reference -->
				<xsl:for-each select="//mixed-citation/text()">
					<!-- set location -->
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
					<!-- now we will interate through regex matching; if we find a match, report it, else run the next test on the non-matching string (avoids duplicates) -->
					<!--
					-->
					<!-- find possible intials then surname -->
					<xsl:analyze-string select="." regex="[^A-Za-z]([A-Z]\.\s?[A-Z\.\s]*\s+[A-Z][a-z]+)">
						<xsl:matching-substring>
							<hit>
								<text>
									<xsl:value-of select="regex-group(1)"/>
								</text>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<!--
							-->
							<!-- find possible surname then initials -->
							<xsl:analyze-string select="." regex="[^A-Za-z]([A-Z][a-z]+,\s+[A-Z]\.\s?[A-Z\.\s]*)">
								<xsl:matching-substring>
									<hit>
										<text>
											<xsl:value-of select="regex-group(1)"/>
										</text>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<!--
									-->
									<!-- find possible name or names then 'ed' -->
									<xsl:analyze-string select="." regex="([A-Z][a-z]+\s+.*)(\s+\(?[Ee]ds?\.?)">
										<xsl:matching-substring>
											<hit>
												<text>
													<xsl:value-of select="regex-group(1)"/>
												</text>
												<xsl:copy-of select="$location"/>
											</hit>
										</xsl:matching-substring>
										<xsl:non-matching-substring>
											<!--
											-->
											<!-- find possible name or names then 'trans' -->
											<xsl:analyze-string select="." regex="([A-Z][a-z]+\s+.*)(\s+\(?[Tt]rans?\.?)">
												<xsl:matching-substring>
													<hit>
														<text>
															<xsl:value-of select="regex-group(1)"/>
														</text>
														<xsl:copy-of select="$location"/>
													</hit>
												</xsl:matching-substring>
												<xsl:non-matching-substring>
													<!--
													-->
													<!-- find 'in' then possible name or names -->
													<xsl:analyze-string select="." regex="[^A-Za-z][Ii]n\s+([A-Z][a-z\.].+)">
														<xsl:matching-substring>
															<hit>
																<text>
																	<xsl:value-of select="regex-group(1)"/>
																</text>
																<xsl:copy-of select="$location"/>
															</hit>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:non-matching-substring>
											</xsl:analyze-string>
										</xsl:non-matching-substring>
									</xsl:analyze-string>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- set maximum string length for a potential name or collection of names -->
		<xsl:variable name="max_length">100</xsl:variable>
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
					<xsl:for-each select="$hit_list//hit[./text/string-length() lt number($max_length)]">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found possible name(s) in reference: "</xsl:text>
								<xsl:value-of select="./text"/>
								<xsl:text>". </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>At: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>In: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
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
