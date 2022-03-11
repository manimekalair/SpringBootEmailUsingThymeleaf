<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_408" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">408</xsl:variable>
		<xsl:variable name="rule_name">Check for characters from right-to-left alphabets.</xsl:variable>
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
		<!-- build list of text fragments with decimal unicode and location -->
		<xsl:variable name="fragments">
			<xml>
				<!--<xsl:for-each select="//*/text()[not(descendant::*)]">-->
				<xsl:for-each select="//*/text()">
					<fragment>
						<text>
							<xsl:value-of select="."/>
						</text>
						<unicode_dec>
							<xsl:variable name="string" select="string-to-codepoints(.)"/>
							<xsl:for-each select="$string">
								<char>
									<xsl:choose>
										<!-- check for range 0600 to 06FF -->
										<xsl:when test="(number() ge 1536) and (number() le 1791)">
											<xsl:attribute name="type">Arabic</xsl:attribute>
										</xsl:when>
										<!-- check for range 0750 to 077F -->
										<xsl:when test="(number() ge 1872) and (number() le 1919)">
											<xsl:attribute name="type">Arabic</xsl:attribute>
										</xsl:when>
										<!-- check for range FB50 to FDFF -->
										<xsl:when test="(number() ge 64336) and (number() le 65023)">
											<xsl:attribute name="type">Arabic</xsl:attribute>
										</xsl:when>
										<!-- check for range FE70 to FEFF -->
										<xsl:when test="(number() ge 65136) and (number() le 65279)">
											<xsl:attribute name="type">Arabic</xsl:attribute>
										</xsl:when>
										<!-- check for range 0590 to 05FF -->
										<xsl:when test="(number() ge 1424) and (number() le 1535)">
											<xsl:attribute name="type">Hebrew</xsl:attribute>
										</xsl:when>
										<!-- check for range FB1D to FB4F -->
										<xsl:when test="(number() ge 64285) and (number() le 64335)">
											<xsl:attribute name="type">Hebrew</xsl:attribute>
										</xsl:when>
										<!-- check for range 0700 to 074F -->
										<xsl:when test="(number() ge 1792) and (number() le 1871)">
											<xsl:attribute name="type">Syraic</xsl:attribute>
										</xsl:when>
										<!-- check for range 0780 to 07BF -->
										<xsl:when test="(number() ge 1920) and (number() le 1983)">
											<xsl:attribute name="type">Thaana</xsl:attribute>
										</xsl:when>
										<!-- check for range 07C0 to 07FF -->
										<xsl:when test="(number() ge 1984) and (number() le 2047)">
											<xsl:attribute name="type">N'ko</xsl:attribute>
										</xsl:when>
									</xsl:choose>
									<xsl:value-of select="."/>
								</char>
							</xsl:for-each>
						</unicode_dec>
						<location>
							<xsl:choose>
								<xsl:when test="./ancestor::*[@id][1]">
									<xsl:attribute name="loc_type">element</xsl:attribute>
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="name(./ancestor::*[@id][1])"/>
									<xsl:text> id="</xsl:text>
									<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
									<xsl:text>"&gt;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="loc_type">xpath</xsl:attribute>
									<xsl:for-each select="ancestor::*">
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</location>
					</fragment>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- build list of hits -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="$fragments//fragment">
					<xsl:choose>
						<xsl:when test="count(.//char[@type]) =0"/>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
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
				<xsl:when test="count($hit_list//fragment) = 0">
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class">pass</xsl:attribute>
							<xsl:text>pass</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$hit_list//fragment">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found text from right-to-left alphabet (</xsl:text>
								<xsl:value-of select=".//@type[not(. = parent::char/preceding-sibling::char/@type)]"/>
								<xsl:text>) at: </xsl:text>
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
