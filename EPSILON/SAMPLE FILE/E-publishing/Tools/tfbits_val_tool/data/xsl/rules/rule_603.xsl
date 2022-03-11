<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_603" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">603</xsl:variable>
		<xsl:variable name="rule_name">Check that artwork files are named as per our convention.</xsl:variable>
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
		<!-- import filelist.xml -->
		<xsl:variable name="filelist">
			<!--
			-->
			<!-- tokenize document path -->
			<xsl:variable name="tokenized_string" select="tokenize(base-uri(),'[/\\]')"/>
			<!--
			-->
			<!-- split out tokenized document path and tag -->
			<xsl:variable name="tokenized_tagged">
				<xml>
					<xsl:for-each select="$tokenized_string">
						<tag>
							<xsl:value-of select="."/>
						</tag>
					</xsl:for-each>
				</xml>
			</xsl:variable>
			<!--
			-->
			<!-- get filename -->
			<xsl:variable name="filename" select="$tokenized_tagged//tag[last()]"/>
			<!--
			-->
			<!-- build path -->
			<xsl:variable name="filelist_path" select="replace(base-uri(),$filename,'filelist.xml')"/>
			<!--
			-->
			<!-- load filelist.xml -->
			<xsl:copy-of select="document($filelist_path)"/>
			<!--
			-->
		</xsl:variable>
		<!--
		-->
		<!-- build list of filenames, prefixes, and suffixes, exclusing extension -->
		<xsl:variable name="name_list">
			<xml>
				<!--
				-->
				<!-- select all files in artwork folder -->
				<xsl:for-each select="$filelist//folder[@path = 'artwork/']/filename">
					<!--
					-->
					<!-- tokenize filename on full point -->
					<xsl:variable name="tokenized_name" select="tokenize(.,'\.')"/>
					<!--
					-->
					<!-- get filename -->
					<xsl:variable name="tokenized_name_tagged">
						<xml>
							<xsl:for-each select="$tokenized_name">
								<tag>
									<xsl:value-of select="."/>
								</tag>
							</xsl:for-each>
						</xml>
					</xsl:variable>
					<!--
					-->
					<!-- get filename -->
					<xsl:variable name="filename">
						<xsl:for-each select="$tokenized_name_tagged//tag[not(position()=last())]">
							<xsl:value-of select="."/>
							<xsl:if test="position() lt last()">
								<xsl:text>.</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<!--
					-->
					<name>
						<full>
							<xsl:value-of select="$filename"/>
						</full>
						<prefix>
							<xsl:value-of select="substring($filename,1,3)"/>
						</prefix>
						<suffix>
							<xsl:value-of select="substring($filename,4)"/>
						</suffix>
					</name>
					<!--
					-->
				</xsl:for-each>
				<!--
				-->
			</xml>
		</xsl:variable>
		<!--
		-->
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="$name_list//name">
					<!--
					-->
					<!-- test if prefix is all lowercase letters -->
					<xsl:if test="string-length(replace(./prefix,'[a-z]','')) gt 0">
						<hit type="1_prefix">
							<xsl:copy-of select="./full"/>
							<xsl:copy-of select="./prefix"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test if suffix contains a full point -->
					<xsl:if test="contains(./suffix,'.')">
						<hit type="2_fullpoint">
							<xsl:copy-of select="./full"/>
							<xsl:copy-of select="./suffix"/>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test if suffix starts with a number -->
					<xsl:if test="not(matches(./suffix,'^[0-9]'))">
						<hit type="3_starts_num">
							<xsl:copy-of select="./full"/>
							<xsl:copy-of select="./suffix"/>
						</hit>
					</xsl:if>
					<!--
					-->
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
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class" select="$error_type"/>
							<xsl:text>Found filenames that may not match convention:</xsl:text>
							<xsl:element name="ul">
								<xsl:for-each select="$hit_list//hit">
									<xsl:sort select="@type"/>
									<xsl:element name="li">
										<xsl:choose>
											<xsl:when test="@type = '1_prefix'">
												<xsl:text>Three letter prefix ("</xsl:text>
												<xsl:value-of select="./prefix"/>
												<xsl:text>") is not all lowercase: "</xsl:text>
											</xsl:when>
											<xsl:when test="@type = '2_fullpoint'">
												<xsl:text>Suffix ("</xsl:text>
												<xsl:value-of select="./suffix"/>
												<xsl:text>") contains a full point: "</xsl:text>
											</xsl:when>
											<xsl:when test="@type = '3_starts_num'">
												<xsl:text>Suffix ("</xsl:text>
												<xsl:value-of select="./suffix"/>
												<xsl:text>") does not start with a number: "</xsl:text>
											</xsl:when>
										</xsl:choose>
										<xsl:value-of select="./full"/>
										<xsl:text>"</xsl:text>
									</xsl:element>
								</xsl:for-each>
							</xsl:element>
						</xsl:element>
					</xsl:element>
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
