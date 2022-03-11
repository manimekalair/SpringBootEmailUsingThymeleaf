<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	<!--
	Sion refactor
	/book-meta/book-id/@pub-id-type='doi')"
	to 
	//book-meta/book-id/@book-id-type='doi')"
	-->

	<!-- use xsl to validate doi's/ISBN-->
	<xsl:template name="rule_012">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">012</xsl:variable>
		<xsl:variable name="rule_name">Validate the book DOI.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>

		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:call-template name="rule_details">
				<xsl:with-param name="rule_number" select="$rule_number"/>
				<xsl:with-param name="rule_name" select="$rule_name"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!-- insert setting of variables, testing, and any processing of data here -->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="./book-meta/book-id">
					<xsl:for-each select="./book-meta/book-id">
						<xsl:variable name="myPassedISBN"
							select="replace(., '(10.4324/|10.1201/)', '')"/>
						<xsl:variable name="myPassedISBN"
							select="replace($myPassedISBN, '[^\dX]', '')"/>
						<xsl:choose>
							<xsl:when test="not(./@book-id-type = 'doi')">
								<tr>
									<xsl:copy-of select="$rule_details"/>
									<td class="fail">missing book-id-type="doi" – no book DOI
										found</td>
								</tr>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="not(matches(., '^(10.4324/|10.1201/)'))">
										<tr>
											<xsl:copy-of select="$rule_details"/>
											<td class="fail">DOI does not start "10.4324/" or
												"10.1201/" ("<xsl:value-of select="."/>")</td>
										</tr>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="string-length($myPassedISBN) = 13">
												<xsl:variable name="check">
												<xsl:call-template name="isbn13Validator">
												<xsl:with-param name="myPassedISBN"
												select="$myPassedISBN"/>
												</xsl:call-template>
												</xsl:variable>
												<xsl:if
												test="not(normalize-space($check) = 'valid')">
												<tr>
												<xsl:copy-of select="$rule_details"/>
												<td class="fail">
												<xsl:value-of select="$myPassedISBN"/> – ISBN is
												not valid </td>
												</tr>
												</xsl:if>

											</xsl:when>
											<xsl:otherwise>
												<tr>
												<xsl:copy-of select="$rule_details"/>
												<td class="fail">
												<em>
												<xsl:value-of select="$myPassedISBN"/>
												</em> is <strong>not</strong> 13 digits</td>
												</tr>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">no book-id</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>