<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_810" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">810</xsl:variable>
		<xsl:variable name="rule_name">Check name tagging.</xsl:variable>
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
				
				<!-- find disallowed children of mixed-citation -->
				<xsl:for-each select="//mixed-citation/(string-name|name|collab)">
					<hit type="disallowed-child">
						<element>
							<xsl:value-of select="name()"/>
						</element>
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
				</xsl:for-each>
				
				<!-- check @person-group-type -->
				<xsl:for-each select="//mixed-citation/person-group[not(matches(@person-group-type, '^(author|editor|translator|other)$'))]">
					<hit type="person-group-type">
						<value>
							<xsl:value-of select="@person-group-type"/>
						</value>
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
				</xsl:for-each>
				
				<!-- check for name in person-group -->
				<xsl:for-each select="//mixed-citation/person-group/name">
					<hit type="name">
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
					<xsl:for-each select="$hit_list/xml/hit[@type='disallowed-child']">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td>
								<xsl:text>Found disallowed &lt;</xsl:text>
								<xsl:value-of select="./element"/>
								<xsl:text>&gt; element in &lt;mixed-citation&gt; </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="$hit_list/xml/hit[@type='person-group-type']">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td>
								<xsl:text>Found a &lt;person-group&gt; element that does not have a person-group-type attribute of "author", "editor", "translator", or "other" </xsl:text>
								<xsl:if test="string-length(./value) &gt; 0">(value is "<xsl:value-of select="./value"/>") </xsl:if>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="$hit_list/xml/hit[@type='name']">
						<tr>
							<td>
								<xsl:text>Found a &lt;name&gt; element in &lt;person-group&gt; </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
							</td>
						</tr>
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
