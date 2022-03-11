<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:mml="http://www.w3.org/1998/Math/MathML">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_451" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">451</xsl:variable>
		<xsl:variable name="rule_name">Check that &lt;mml:math&gt; has the correct @display attribute.</xsl:variable>
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
		<!-- built list of maths -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="//mml:math">
					<xsl:choose>
						<xsl:when test="ancestor::disp-formula and @display = 'inline'">
							<hit>
								<type>displayed-inline</type>
								<location>
									<xsl:choose>
										<xsl:when test="./ancestor::*[@id][1]">
											<xsl:attribute name="type">element</xsl:attribute>
											<xsl:text>&lt;</xsl:text>
											<xsl:value-of select="name(./ancestor::*[@id][1])"/>
											<xsl:text> id="</xsl:text>
											<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
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
						</xsl:when>
						<xsl:when test="ancestor::inline-formula and @display = 'block'">
							<hit>
								<type>inline-block</type>
								<location>
									<xsl:choose>
										<xsl:when test="./ancestor::*[@id][1]">
											<xsl:attribute name="type">element</xsl:attribute>
											<xsl:text>&lt;</xsl:text>
											<xsl:value-of select="name(./ancestor::*[@id][1])"/>
											<xsl:text> id="</xsl:text>
											<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
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
						</xsl:when>
						<xsl:when test="not(@display)">
							<hit>
								<type>no-display</type>
								<location>
									<xsl:choose>
										<xsl:when test="./ancestor::*[@id][1]">
											<xsl:attribute name="type">element</xsl:attribute>
											<xsl:text>&lt;</xsl:text>
											<xsl:value-of select="name(./ancestor::*[@id][1])"/>
											<xsl:text> id="</xsl:text>
											<xsl:value-of select="./ancestor::*[@id][1]/@id"/>
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
						</xsl:when>
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
						<xsl:sort select="./type" order="ascending"/>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:choose>
									<xsl:when test="./type = 'displayed-inline'">
										<xsl:text>Found &lt;disp-formula&gt; with inline MathML (&lt;mml:math display="inline"&gt;) at: </xsl:text>
										<xsl:value-of select="./location"/>
									</xsl:when>
									<xsl:when test="./type = 'inline-block'">
										<xsl:text>Found &lt;inline-formula&gt; with block MathML (&lt;mml:math display="block"&gt;) at: </xsl:text>
										<xsl:value-of select="./location"/>
									</xsl:when>
									<xsl:when test="./type = 'no-display'">
										<xsl:text>Found MathML &lt;mml:math&gt; element with no @display attribute at: </xsl:text>
										<xsl:value-of select="./location"/>
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
