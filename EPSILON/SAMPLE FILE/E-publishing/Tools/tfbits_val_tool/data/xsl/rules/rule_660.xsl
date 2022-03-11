<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_660" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">660</xsl:variable>
		<xsl:variable name="rule_name">Check for untagged source information.</xsl:variable>
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
				<!-- select all nodes in list that are not attrib -->
				<xsl:for-each select="//disp-quote/node()[not(self::attrib)][last()]">
					<xsl:variable name="temp_text" select="."/>
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
					<!-- test if string starts with 'source', 'after', 'from' -->
					<xsl:analyze-string select="lower-case(.)" regex="(^source|^after|^from)(.+)">
						<xsl:matching-substring>
							<hit type="start_word">
								<text>
									<xsl:value-of select="$temp_text"/>
								</text>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if string starts with '(' and ends with ')' -->
					<xsl:analyze-string select="lower-case(.)" regex="(^\(.+\)$)">
						<xsl:matching-substring>
							<hit type="parentheses">
								<text>
									<xsl:value-of select="$temp_text"/>
								</text>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if string starts with '[' and ends with ']' -->
					<xsl:analyze-string select="lower-case(.)" regex="(^\[.+\]$)">
						<xsl:matching-substring>
							<hit type="brackets">
								<text>
									<xsl:value-of select="$temp_text"/>
								</text>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if element contains reference xref -->
					<xsl:if test=".//xref[@ref-type='bibr' and @rid]">
						<hit type="reference">
							<text>
								<xsl:value-of select="$temp_text"/>
							</text>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all italic -->
					<xsl:if test="./italic and count(child::node()) = 1">
						<hit type="italic">
							<text>
								<xsl:value-of select="$temp_text"/>
							</text>
							<xsl:copy-of select="$location"/>
						</hit>
					</xsl:if>
					<!-- test if element is all italic and includes a page marker xref -->
					<xsl:if test="./italic and (count(child::node()) = 2) and (./target[@target-type = 'page' and matches(@id,'page_')])">
						<hit type="italic">
							<text>
								<xsl:value-of select="$temp_text"/>
							</text>
							<xsl:copy-of select="$location"/>
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
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found possible extract source not tagged &lt;attrib&gt; in: </xsl:text>
								<xsl:value-of select="./location"/>
								<xsl:text> – "</xsl:text>
								<xsl:choose>
									<xsl:when test="string-length(./text) lt 60">
										<xsl:value-of select="./text"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="substring(./text,1,60)"/>
										<xsl:text> ...</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>" (</xsl:text>
								<xsl:choose>
									<xsl:when test="./@type='start_word'">
										<xsl:text>starts with word that may indicate a source line</xsl:text>
									</xsl:when>
									<xsl:when test="./@type='parentheses'">
										<xsl:text>encapsulated in parentheses</xsl:text>
									</xsl:when>
									<xsl:when test="./@type='brackets'">
										<xsl:text>encapsulated in brackets</xsl:text>
									</xsl:when>
									<xsl:when test="./@type='reference'">
										<xsl:text>contains a reference citation</xsl:text>
									</xsl:when>
									<xsl:when test="./@type='italic'">
										<xsl:text>is styled italic</xsl:text>
									</xsl:when>
								</xsl:choose>
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
