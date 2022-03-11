<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_680" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">680</xsl:variable>
		<xsl:variable name="rule_name">Check that dialogue is tagged &lt;speech&gt; and &lt;speaker&gt;.</xsl:variable>
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
				<!-- select text in all elements with no descendants -->
				<xsl:for-each select="//text()[(count(preceding-sibling::text()) = 0) and (not(ancestor-or-self::ref or ancestor-or-self::title or ancestor-or-self::table-wrap or ancestor-or-self::italic or ancestor-or-self::bold))]">
					<!-- pass location of element to variable -->
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
					<!-- test for all-caps text -->
					<xsl:analyze-string select="." regex="(^[A-ZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞĀĂĄĆĈĊČĎĐĒĔĖĘĚĜĞĠĢĤĦĨĪĬĮİĲĴĶĹĻĽĿŁŃŅŇŊŌŎŐŒŔŖŘŚŜŞŠŢŤŦŨŪŬŮŰŲŴŶŸŹŻŽ ]+:\s+.+)">
						<xsl:matching-substring>
							<hit type="all-caps">
								<text>
									<xsl:value-of select="regex-group(1)"/>
								</text>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:for-each>
				<!--
				
				-->
				<!--- select any text that follows sc, bold, or italic, when that element is the first thing in its parent -->
				<xsl:for-each select="//*[self::italic or self::bold or self::sc][count(preceding-sibling::text()) = 0]/following-sibling::text()[1]">
					<xsl:variable name="preceding">
						<preceding>
							<xsl:attribute name="name" select="name(preceding-sibling::*[1])"/>
							<xsl:value-of select="preceding-sibling::*[1]"/>
						</preceding>
					</xsl:variable>
					<!-- pass location of element to variable -->
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
					<!-- filter out hits based on structure -->
					<xsl:choose>
						<xsl:when test="ancestor-or-self::imprint-meta"/>
						<xsl:when test="ancestor-or-self::attrib"/>
						<xsl:otherwise>						
							<!-- test if the string starts with a colon-->
							<xsl:analyze-string select="." regex="(^:\s+.+)">
								<xsl:matching-substring>
									<hit type="label">
										<xsl:copy-of select="$preceding"/>
										<text>
											<xsl:value-of select="regex-group(1)"/>
										</text>
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
					<xsl:for-each select="$hit_list//hit">
						<!-- set text variable to found text, or shortened version if more that 60 characters -->
						<xsl:variable name="text">
							<xsl:choose>
								<xsl:when test="string-length(./text) lt 60">
									<xsl:value-of select="./text"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring(./text,1,60)"/>
									<xsl:text> ...</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found possible dialogue: "</xsl:text>
								<xsl:if test="@type = 'all-caps'">
									<xsl:value-of select="$text"/>
								</xsl:if>
								<xsl:if test="@type = 'label'">
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="./preceding/@name"/>
									<xsl:text>&gt;</xsl:text>
									<xsl:value-of select="./preceding"/>
									<xsl:text>&lt;/</xsl:text>
									<xsl:value-of select="./preceding/@name"/>
									<xsl:text>&gt;</xsl:text>
									<xsl:value-of select="$text"/>
									<xsl:text>"</xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text> (at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text> (in: </xsl:text>
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
