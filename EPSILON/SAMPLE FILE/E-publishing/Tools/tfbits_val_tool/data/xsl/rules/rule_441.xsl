<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_441" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">441</xsl:variable>
		<xsl:variable name="rule_name">Check for untagged names for section contributors.</xsl:variable>
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
				<xsl:for-each select="(//sec|//app)/p[1]">
					<!--
					-->
					<xsl:choose>
						<!--
						-->
						<!-- only test on strings less that 100 characters -->
						<xsl:when test="string-length(.) lt 100">
							<!--
							-->
							<!-- set variables for reporting-->
							<xsl:variable name="string-full" select="."/>
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
							<!-- remove punctuation from string -->
							<xsl:variable name="string-no-punct" select="replace(.,',;:\\/\\','')"/>
							<!--
							-->
							<!-- remove ands from string -->
							<xsl:variable name="string-no-and">
								<xsl:choose>
									<!--
									-->
									<!-- remove ands -->
									<xsl:when test="contains($string-no-punct,' and ')">
										<xsl:value-of select="substring-before($string-no-punct,' and ')"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="substring-after($string-no-punct,' and ')"/>
									</xsl:when>
									<!--
									-->
									<!-- remove & -->
									<xsl:when test="contains($string-no-punct,' &amp; ')">
										<xsl:value-of select="substring-before($string-no-punct,' &amp; ')"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="substring-after($string-no-punct,' &amp; ')"/>
									</xsl:when>
									<!--
									-->
									<!-- remove with -->
									<xsl:when test="contains($string-no-punct,' with ')">
										<xsl:value-of select="substring-before($string-no-punct,' with ')"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="substring-after($string-no-punct,' with ')"/>
									</xsl:when>
									<!--
									-->
									<xsl:otherwise>
										<xsl:value-of select="$string-no-punct"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<!--
							-->
							<xsl:variable name="test-string" select="$string-no-and"/>
							<!--
							-->
							<!-- test if there is an all lower-case word in string and if so, discard the string. Else, run another test -->
							<xsl:analyze-string select="$test-string" regex=".+\s+[a-z]+\s+.+">
								<xsl:matching-substring/>
								<xsl:non-matching-substring>
									<!--
									-->
									<!-- test if string is at least two words long -->
									<xsl:analyze-string select="." regex=".+\s+.+">
										<xsl:matching-substring>
											<hit>
												<text>
													<xsl:value-of select="$string-full"/>
												</text>
												<xsl:copy-of select="$location"/>
											</hit>
										</xsl:matching-substring>
									</xsl:analyze-string>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
							<!--
							-->
						</xsl:when>
					</xsl:choose>
					<!--
					-->
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
								<xsl:text>Found possible untagged authors for section: "</xsl:text>
								<xsl:value-of select="./text"/>
								<xsl:text>" (</xsl:text>
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
