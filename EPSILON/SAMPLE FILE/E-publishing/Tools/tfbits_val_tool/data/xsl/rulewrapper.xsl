<?xml version="1.0" encoding="us-ascii"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--
	-->
	<!-- import all individual rules -->
	<xsl:import href="rule_importer.xsl"/>
	<!--
	-->
	<!-- import all isbn validator -->
	<xsl:import href="isbn_validator.xsl"/>
	<!--
	-->
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="us-ascii"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="/book">
		<body>
			<title>
				<xsl:value-of select=".//book-title"/>: <xsl:value-of select=".//book-id"/>
			</title>
			<div class="header">
				<p>Report on: <span class="title">
						<xsl:value-of select=".//book-title"/>
					</span>
				</p>
				<p>Validation type: External Supplier</p>
				<p>ISBN: <span class="captureISBN">
						<xsl:value-of select=".//book-id/substring-after(.,'/')"/>
					</span>
				</p>
				<p>Publisher-name: <span class="publisher">
						<xsl:value-of select=".//publisher[1]//publisher-name"/>
					</span>
				</p>
				<p>Supplier info: <span class="supplier">
						<xsl:for-each select=".//notes[@notes-type='supplier']/p">
							<xsl:value-of select="."/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</span>
				</p>
				<xsl:for-each select="/book/book-meta/isbn">
					<p>
						<span>
							<xsl:attribute name="class"><xsl:value-of select="./@publication-format"/></xsl:attribute>
							<xsl:text>ISBN (</xsl:text>
							<xsl:value-of select="./@publication-format"/>
							<xsl:text>): </xsl:text>
							<xsl:value-of select="."/>
						</span>
					</p>
				</xsl:for-each>
				<p>Run: <span class="parsedate">
						<xsl:value-of select="format-date(
                                 current-date(),
                                 '[FNn], [D1o] [MNn,*-3], [Y]',
                                 'en',
                                 (),
                                 ()
                              )"/>
					</span>
				</p>
			</div>
			<div class="delivery">
				<filename/>
			</div>
			<div class="report">
				<div class="report_section">
				<h2>Book meta</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- book meta -->
					<xsl:call-template name="rule_001"/>
					<xsl:call-template name="rule_006"/>
					<xsl:call-template name="rule_007"/>
					<xsl:call-template name="rule_008"/>
					<xsl:call-template name="rule_009"/>
					<xsl:call-template name="rule_010"/>
					<xsl:call-template name="rule_011"/>
					<xsl:call-template name="rule_012"/>
					<xsl:call-template name="rule_013"/>
					<xsl:call-template name="rule_014"/>
					<xsl:call-template name="rule_016"/>
					<xsl:call-template name="rule_018"/>
					<xsl:call-template name="rule_019"/>
					<xsl:call-template name="rule_020"/>
					<xsl:call-template name="rule_021"/>
					<xsl:call-template name="rule_022"/>
					<xsl:call-template name="rule_023"/>
					<xsl:call-template name="rule_024"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Imprint page</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- imprint page -->
					<xsl:call-template name="rule_101"/>
					<xsl:call-template name="rule_102"/>
					<xsl:call-template name="rule_103"/>
					<xsl:call-template name="rule_104"/>
					<xsl:call-template name="rule_105"/>
					<xsl:call-template name="rule_106"/>
					<xsl:call-template name="rule_107"/>
					<xsl:call-template name="rule_108"/>
					<xsl:call-template name="rule_109"/>
					<xsl:call-template name="rule_111"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Book frontmatter</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- book frontmatter -->
					<xsl:call-template name="rule_201"/>
					<xsl:call-template name="rule_202"/>
					<xsl:call-template name="rule_203"/>
					<xsl:call-template name="rule_204"/>
					<xsl:call-template name="rule_205"/>
					<xsl:call-template name="rule_206"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Book parts/chapters Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- book part -->
					<xsl:call-template name="rule_301"/>
					<xsl:call-template name="rule_303"/>
					<xsl:call-template name="rule_304"/>
					<xsl:call-template name="rule_305"/>
					<xsl:call-template name="rule_306"/>
					<xsl:call-template name="rule_307"/>
					<xsl:call-template name="rule_308"/>
					<xsl:call-template name="rule_309"/>
					<xsl:call-template name="rule_310"/>
					<xsl:call-template name="rule_311"/>
					<xsl:call-template name="rule_312"/>
					<xsl:call-template name="rule_313"/>
					<xsl:call-template name="rule_315"/>
					<xsl:call-template name="rule_316"/>
					<xsl:call-template name="rule_317"/>
					<xsl:call-template name="rule_318"/>
					<xsl:call-template name="rule_321"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>General Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- general -->
					<xsl:call-template name="rule_401"/>
					<xsl:call-template name="rule_402"/>
					<xsl:call-template name="rule_404"/>
					<xsl:call-template name="rule_405"/>
					<xsl:call-template name="rule_406"/>
					<xsl:call-template name="rule_407"/>
					<xsl:call-template name="rule_408"/>
					<xsl:call-template name="rule_409"/>
					<xsl:call-template name="rule_410"/>
					<xsl:call-template name="rule_411"/>
					<xsl:call-template name="rule_412"/>
					<xsl:call-template name="rule_413"/>
					<xsl:call-template name="rule_414"/>
					<xsl:call-template name="rule_415"/>
					<xsl:call-template name="rule_416"/>
					<xsl:call-template name="rule_417"/>
					<xsl:call-template name="rule_418"/>
					<xsl:call-template name="rule_419"/>
					<xsl:call-template name="rule_420"/>
					<xsl:call-template name="rule_421"/>
					<xsl:call-template name="rule_422"/>
					<xsl:call-template name="rule_423"/>
					<xsl:call-template name="rule_424"/>
					<xsl:call-template name="rule_425"/>
					<xsl:call-template name="rule_426"/>
					<xsl:call-template name="rule_427"/>
					<xsl:call-template name="rule_428"/>
					<xsl:call-template name="rule_429"/>
					<xsl:call-template name="rule_430"/>
					<xsl:call-template name="rule_431"/>
					<xsl:call-template name="rule_432"/>
					<xsl:call-template name="rule_433"/>
					<xsl:call-template name="rule_434"/>
					<xsl:call-template name="rule_435"/>
					<xsl:call-template name="rule_437"/>
					<xsl:call-template name="rule_438"/>
					<xsl:call-template name="rule_440"/>
					<xsl:call-template name="rule_441"/>
					<xsl:call-template name="rule_442"/>
					<xsl:call-template name="rule_443"/>
					<xsl:call-template name="rule_445"/>
					<xsl:call-template name="rule_447"/>
					<xsl:call-template name="rule_448"/>
					<xsl:call-template name="rule_449"/>
					<xsl:call-template name="rule_450"/>
					<xsl:call-template name="rule_451"/>
					<xsl:call-template name="rule_452"/>
					<xsl:call-template name="rule_453"/>
					<xsl:call-template name="rule_454"/>
					<xsl:call-template name="rule_455"/>
					<xsl:call-template name="rule_456"/>
					<xsl:call-template name="rule_457"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Citation Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- cross-references -->
					<xsl:call-template name="rule_501"/>
					<xsl:call-template name="rule_502"/>
					<xsl:call-template name="rule_504"/>
					<xsl:call-template name="rule_505"/>
					<xsl:call-template name="rule_506"/>
					<xsl:call-template name="rule_507"/>
					<xsl:call-template name="rule_508"/>
					<xsl:call-template name="rule_509"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<!-- this is a placeholder for the artwork log to get grepped into -->
				<h2>Artwork Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<artwork/>
					<!--
					-->
					<!-- artwork -->
					<!--<xsl:call-template name="rule_600"/>-->
					<!--<xsl:call-template name="rule_601"/>-->
					<!--<xsl:call-template name="rule_602"/>-->
					<!--<xsl:call-template name="rule_603"/>-->
					<!--<xsl:call-template name="rule_604"/>-->
					<xsl:call-template name="rule_605"/>
					<xsl:call-template name="rule_607"/>
					<xsl:call-template name="rule_608"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Table Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- tables -->
					<xsl:call-template name="rule_620"/>
					<xsl:call-template name="rule_621"/>
					<xsl:call-template name="rule_622"/>
					<xsl:call-template name="rule_623"/>
					<xsl:call-template name="rule_624"/>
					<xsl:call-template name="rule_625"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>List Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- lists -->
					<xsl:call-template name="rule_640"/>
					<xsl:call-template name="rule_641"/>
					<xsl:call-template name="rule_642"/>
					<xsl:call-template name="rule_643"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Extract Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- extracts -->
					<xsl:call-template name="rule_660"/>
					<xsl:call-template name="rule_661"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Dialogue Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- extracts -->
					<xsl:call-template name="rule_680"/>
					<xsl:call-template name="rule_681"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>Notes</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- notes -->
					<xsl:call-template name="rule_701"/>
					<xsl:call-template name="rule_702"/>
					<xsl:call-template name="rule_703"/>
					<xsl:call-template name="rule_704"/>
					<xsl:call-template name="rule_706"/>
					<!--
					-->
				</table>
				</div>
				<div class="report_section">
				<h2>References</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!--
					-->
					<!-- references -->
					<xsl:call-template name="rule_801"/>
					<xsl:call-template name="rule_802"/>
					<xsl:call-template name="rule_803"/>
					<xsl:call-template name="rule_804"/>
					<xsl:call-template name="rule_805"/>
					<xsl:call-template name="rule_806"/>
					<xsl:call-template name="rule_807"/>
					<xsl:call-template name="rule_808"/>
					<xsl:call-template name="rule_809"/>
					<xsl:call-template name="rule_810"/>
					<xsl:call-template name="rule_811"/>
					<xsl:call-template name="rule_812"/>
					<xsl:call-template name="rule_813"/>
					<xsl:call-template name="rule_814"/>
					<xsl:call-template name="rule_815"/>
					<xsl:call-template name="rule_816"/>
					<xsl:call-template name="rule_817"/>
					<xsl:call-template name="rule_818"/>
					<xsl:call-template name="rule_819"/>
					<xsl:call-template name="rule_820"/>
					<xsl:call-template name="rule_821"/>
					<xsl:call-template name="rule_822"/>
					<xsl:call-template name="rule_823"/>
					<xsl:call-template name="rule_824"/>
					<xsl:call-template name="rule_825"/>
					<xsl:call-template name="rule_827"/>
					<xsl:call-template name="rule_828"/>
					<xsl:call-template name="rule_829"/>
					<xsl:call-template name="rule_830"/>
					<xsl:call-template name="rule_831"/>
					<xsl:call-template name="rule_832"/>
					<xsl:call-template name="rule_833"/>
					<xsl:call-template name="rule_834"/>
					<xsl:call-template name="rule_835"/>
					<xsl:call-template name="rule_836"/>
					<xsl:call-template name="rule_837"/>
					<xsl:call-template name="rule_838"/>
					<xsl:call-template name="rule_839"/>
					<xsl:call-template name="rule_840"/>
					<xsl:call-template name="rule_841"/>
					<xsl:call-template name="rule_842"/>
					<!--
					-->
				</table>
				</div>
				<!--<div class="report_section">
				<h2>Index Checks</h2>
				<table>
					<tr>
						<th>Rule</th>
						<th>Result</th>
					</tr>
					<!-\-
					-\->
					<!-\- notes -\->
					<xsl:call-template name="rule_901"/>
					<xsl:call-template name="rule_902"/>
					<xsl:call-template name="rule_903"/>
					<xsl:call-template name="rule_904"/>
					<xsl:call-template name="rule_905"/>
					<xsl:call-template name="rule_906"/>
					<xsl:call-template name="rule_907"/>
					<xsl:call-template name="rule_908"/>
					<!-\-
					-\->
				</table>
				</div>
			--></div>
		</body>
	</xsl:template>
	<!--
	-->
	<xsl:template match="*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	<!--
	-->
	<!-- template to determine if an error was found if not return default text-->
	<xsl:template name="display_result">
		<xsl:param name="result"/>
		<xsl:param name="rule_details"/>
		<xsl:if test="not($result/*)">
			<tr>
				<xsl:copy-of select="$rule_details"/>
				<td class="pass">pass</td>
			</tr>
		</xsl:if>
		<xsl:if test="$result/*">
			<xsl:copy-of select="$result"/>
		</xsl:if>
	</xsl:template>
	<!--
	-->
	<!--template to build rule_details -->
	<xsl:template name="rule_details">
		<xsl:param name="rule_number"/>
		<xsl:param name="rule_name"/>
		<xsl:element name="td">
			<xsl:element name="span">
				<xsl:attribute name="class">rule</xsl:attribute>
				<xsl:text>Rule </xsl:text>
				<xsl:value-of select="$rule_number"/>
			</xsl:element>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="$rule_name"/>
		</xsl:element>
	</xsl:template>
	
	<!-- template to display message -->
	<xsl:template name="message">
		<xsl:param name="rule_number"/>
		<xsl:message>
			<xsl:text>Checking Rule </xsl:text>
			<xsl:value-of select="$rule_number"/>
		</xsl:message>
	</xsl:template>
	
</xsl:stylesheet>
