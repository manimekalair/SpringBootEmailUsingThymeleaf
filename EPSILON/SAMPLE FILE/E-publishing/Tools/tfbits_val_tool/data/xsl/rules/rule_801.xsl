<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_801" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">801</xsl:variable>
		<xsl:variable name="rule_name">Punctuation check.</xsl:variable>
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
		<!-- build list of lowest level ref elements -->
		<xsl:variable name="ref_elements">
			<xml>
				<xsl:for-each select="//mixed-citation//*[not(descendant::*)]">
					<element>
						<xsl:copy-of select="." copy-namespaces="no"/>
						<following_text>
							<xsl:value-of select="following-sibling::text()"/>
						</following_text>
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
						<parent>
							<xsl:value-of select="name(parent::*)"/>
						</parent>
					</element>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- build list of ref string-names -->
		<xsl:variable name="ref_string-name">
			<xml>
				<xsl:for-each select="//mixed-citation//string-name">
					<element>
						<text>
							<xsl:value-of select="."/>
						</text>
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
					</element>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<!-- check for full point at the end of element content -->
				<xsl:for-each select="$ref_elements//element/*[1][not(self::given-names or self::prefix or self::suffix or self::etal)]">
					<xsl:variable name="test" select="."/>
					
					<xsl:variable name="parent" select="following-sibling::parent"/>
					
					<xsl:variable name="location" select="following-sibling::location"/>
					<!--
					-->
					<!-- test for exceptions where a full point at the end if valid (company suffixes; US state abbreviations; misc reference words) -->
					<xsl:analyze-string select="$test" regex="(Ltd|Inc|Co|D\.C|Ala|Ariz|Ark|Calif|Colo|Conn|Del|Fla|Ga|Ill|Ind|Kans|Ky|La|Md|Mass|Mich|Minn|Miss|Mo|Mont|Nebr|Nev|N\.H|N\.J|N\.M|N\.Y|N\.C|N\.D|Okla|Ore|Pa|R\.I|S\.C|S\.D|Tenn|Tex|Vt|Va|Wash|W\.Va|Wis|Wyo|[Ss]uppl)\.$">
						<xsl:matching-substring/>
						<xsl:non-matching-substring>
							<!--
							-->
							<!-- test for full point at the end of string -->
							<xsl:analyze-string select="." regex="\.$">
								<xsl:matching-substring>
									<hit type="punctuation" order="1">
										<xsl:copy-of select="$test"/>
										<parent>
											<xsl:value-of select="$parent"/>
										</parent>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:for-each>
				<!--
				-->
				<!-- check for other punctuation at the end of element content -->
				<xsl:for-each select="$ref_elements//element/*[1]">
					<xsl:variable name="test" select="."/>
					<xsl:variable name="parent" select="following-sibling::parent"/>
					<xsl:variable name="location" select="following-sibling::location"/>
					<!--
					-->
					<!-- check for other punctuation at the end of element content -->
					<xsl:analyze-string select="$test" regex="(,|;|:|–|—|—|‒|―|⸺|⸻|-|‐|−)$">
						<xsl:matching-substring>
							<hit type="punctuation" order="1">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$parent"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- check for space at end of element -->
					<xsl:analyze-string select="$test" regex="\s+$">
						<xsl:matching-substring>
							<hit type="space" order="2">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- check for single quotes around string -->
					<xsl:analyze-string select="$test" regex="^‘.+’$">
						<xsl:matching-substring>
							<hit type="quotes" order="3">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- check for double quotes around string -->
					<xsl:analyze-string select="$test" regex="^“.+”$">
						<xsl:matching-substring>
							<hit type="quotes" order="4">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- check for parentheses around string -->
					<xsl:analyze-string select="$test" regex="^\(.+\)$">
						<xsl:matching-substring>
							<hit type="parentheses" order="5">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- check for brackets around string -->
					<xsl:analyze-string select="$test" regex="^\[.+\]$">
						<xsl:matching-substring>
							<hit type="brackets" order="6">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!--  -->
				</xsl:for-each>
				<!--
				-->
				<xsl:for-each select="$ref_elements//element/*[1]">
					<xsl:variable name="test" select="."/>
					<xsl:variable name="location" select="following-sibling::location"/>
					<!--
					-->
					<!-- count characters -->
					<xsl:variable name="lsquo_count" select="count(string-to-codepoints($test)[. = string-to-codepoints('‘')])"/>
					<xsl:variable name="rsquo_count_temp" select="count(string-to-codepoints($test)[. = string-to-codepoints('’')])"/>
					<xsl:variable name="rsquo_count_apos" select="count($test[matches(.,'([A-Za-z]’s|s’\s|[^\s\d;:\.\?/!]’[^\s\d;:\.\?/!])')])"/>
					<xsl:variable name="rsquo_count" select="$rsquo_count_temp - $rsquo_count_apos"/>
					<xsl:variable name="ldquo_count" select="count(string-to-codepoints($test)[. = string-to-codepoints('“')])"/>
					<xsl:variable name="rdquo_count" select="count(string-to-codepoints($test)[. = string-to-codepoints('”')])"/>
					<xsl:variable name="lpar_count" select="count(string-to-codepoints($test)[. = string-to-codepoints('(')])"/>
					<xsl:variable name="rpar_count" select="count(string-to-codepoints($test)[. = string-to-codepoints(')')])"/>
					<xsl:variable name="lbrak_count" select="count(string-to-codepoints($test)[. = string-to-codepoints('[')])"/>
					<xsl:variable name="rbrak_count" select="count(string-to-codepoints($test)[. = string-to-codepoints(']')])"/>
					<!--
					-->
					<!-- test single quotes match  -->
					<xsl:if test="not($lsquo_count = $rsquo_count)">
						<hit type="mismatch_single_quo" order="7">
							<xsl:copy-of select="$test"/>
							<xsl:copy-of select="$location"/>
							<count type="lsquo">
								<xsl:value-of select="$lsquo_count"/>
							</count>
							<count type="rsquo">
								<xsl:value-of select="$rsquo_count"/>
							</count>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test double quotes match  -->
					<xsl:if test="not($ldquo_count = $rdquo_count)">
						<hit type="mismatch_double_quo" order="8">
							<xsl:copy-of select="$test"/>
							<xsl:copy-of select="$location"/>
							<count type="ldquo">
								<xsl:value-of select="$ldquo_count"/>
							</count>
							<count type="rdquo">
								<xsl:value-of select="$rdquo_count"/>
							</count>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test parentheses match  -->
					<xsl:if test="not($lpar_count = $rpar_count)">
						<hit type="mismatch_paretheses" order="9">
							<xsl:copy-of select="$test"/>
							<xsl:copy-of select="$location"/>
							<count type="lpar">
								<xsl:value-of select="$lpar_count"/>
							</count>
							<count type="rpar">
								<xsl:value-of select="$rpar_count"/>
							</count>
						</hit>
					</xsl:if>
					<!--
					-->
					<!-- test brackets match  -->
					<xsl:if test="not($lbrak_count = $rbrak_count)">
						<hit type="mismatch_brackets" order="10">
							<xsl:copy-of select="$test"/>
							<xsl:copy-of select="$location"/>
							<count type="lbrak">
								<xsl:value-of select="$lbrak_count"/>
							</count>
							<count type="rbrak">
								<xsl:value-of select="$rbrak_count"/>
							</count>
						</hit>
					</xsl:if>
					<!--
				-->
				</xsl:for-each>
				<!--
				-->
				<!-- test for characters following an element -->
				<xsl:for-each select="$ref_elements//element/*[1]">
					<xsl:variable name="test" select="."/>
					<xsl:variable name="location" select="following-sibling::location"/>
					<xsl:variable name="following_text" select="following-sibling::following_text"/>
					<!--
					-->
					<!-- test for question mark after element -->
					<xsl:analyze-string select="$following_text" regex="^\?">
						<xsl:matching-substring>
							<hit type="question_mark" order="11">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- test for exclamation mark after element -->
					<xsl:analyze-string select="$following_text" regex="^!">
						<xsl:matching-substring>
							<hit type="exclamation_mark" order="12">
								<xsl:copy-of select="$test"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:for-each>
				<!--
				-->
				<xsl:for-each select="$ref_string-name//element/text">
					<xsl:variable name="test" select="."/>
					<xsl:variable name="location" select="following-sibling::location"/>
					<!--
					-->
					<!-- test for comma at end of string-name -->
					<xsl:analyze-string select="$test" regex=",$">
						<xsl:matching-substring>
							<hit type="string_name_comma" order="13">
								<string-name>
									<xsl:value-of select="$test"/>
								</string-name>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
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
						<xsl:sort select="./@order" data-type="number" order="ascending"/>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<!--
								-->
								<xsl:variable name="hit_details">
									<xsl:choose>
										<xsl:when test="name(./*[1]) = 'following_text'">
											<xsl:text>(&lt;</xsl:text>
											<xsl:value-of select="./parent"/>
											<xsl:text>&gt;</xsl:text>
											<xsl:text>): "</xsl:text>
											<xsl:value-of select="./*[1]"/>
											<xsl:text>"</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>&lt;</xsl:text>
											<xsl:value-of select="name(./*[1])"/>
											<xsl:text>&gt;</xsl:text>
											<xsl:value-of select="./*[1]"/>
											<xsl:text>&lt;/</xsl:text>
											<xsl:value-of select="name(./*[1])"/>
											<xsl:text>&gt;</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<!--
								-->
								<xsl:variable name="location_details">
									<xsl:text> (</xsl:text>
									<xsl:if test="./location/@type = 'xpath'">
										<xsl:text>at: </xsl:text>
									</xsl:if>
									<xsl:if test="./location/@type = 'element'">
										<xsl:text>in: </xsl:text>
									</xsl:if>
									<xsl:value-of select="./location"/>
									<xsl:text>).</xsl:text>
								</xsl:variable>
								<!--
								-->
								<xsl:choose>
									<xsl:when test="./@type = 'punctuation'">
										<xsl:text>Found punctuation at the end of reference element </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'space'">
										<xsl:text>Found space at the end of reference element: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'quotes'">
										<xsl:text>Found reference element that starts and ends with quotes: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'parentheses'">
										<xsl:text>Found reference element that starts and ends with paretheses: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'brackets'">
										<xsl:text>Found reference element that starts and ends with brackets: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'mismatch_single_quo'">
										<xsl:text>Found reference element that contains a mismatch in single quotemarks: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'mismatch_double_quo'">
										<xsl:text>Found reference element that contains a mismatch in double quotemarks: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'mismatch_paretheses'">
										<xsl:text>Found reference element that contains a mismatch in paretheses: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'mismatch_brackets'">
										<xsl:text>Found reference element that contains a mismatch in brackets: </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'question_mark'">
										<xsl:text>Found reference element that is followed by a question mark (possibly the '?' should be in the element): </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:text>?</xsl:text>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'exclamation_mark'">
										<xsl:text>Found reference element that is followed by an exclamation mark (possibly the '!' should be in the element): </xsl:text>
										<xsl:value-of select="$hit_details"/>
										<xsl:text>!</xsl:text>
										<xsl:value-of select="$location_details"/>
									</xsl:when>
									<!--
									-->
									<xsl:when test="./@type = 'string_name_comma'">
										<xsl:text>Found &lt;string-name&gt; element that ends in a comma: "</xsl:text>
										<xsl:value-of select="./*[1]"/>
										<xsl:text>" </xsl:text>
										<xsl:value-of select="$location_details"/>
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
