<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<!--
	-->
	<!-- book meta -->
	<xsl:import href="rules/rule_001.xsl"/>
	<xsl:import href="rules/rule_006.xsl"/>
	<xsl:import href="rules/rule_007.xsl"/>
	<xsl:import href="rules/rule_008.xsl"/>
	<xsl:import href="rules/rule_009.xsl"/>
	<xsl:import href="rules/rule_010.xsl"/>
	<xsl:import href="rules/rule_011.xsl"/>
	<xsl:import href="rules/rule_012.xsl"/>
	<xsl:import href="rules/rule_013.xsl"/>
	<xsl:import href="rules/rule_014.xsl"/>
	<xsl:import href="rules/rule_016.xsl"/>
	<xsl:import href="rules/rule_018.xsl"/>
	<xsl:import href="rules/rule_019.xsl"/>
	<xsl:import href="rules/rule_020.xsl"/>
	<xsl:import href="rules/rule_021.xsl"/>
	<xsl:import href="rules/rule_022.xsl"/>
	<xsl:import href="rules/rule_023.xsl"/>
	<xsl:import href="rules/rule_024.xsl"/>
	<!--
	-->
	<!-- imprint page -->
	<xsl:import href="rules/rule_101.xsl"/>
	<xsl:import href="rules/rule_102.xsl"/>
	<xsl:import href="rules/rule_103.xsl"/>
	<xsl:import href="rules/rule_104.xsl"/>
	<xsl:import href="rules/rule_105.xsl"/>
	<xsl:import href="rules/rule_106.xsl"/>
	<xsl:import href="rules/rule_107.xsl"/>
	<xsl:import href="rules/rule_108.xsl"/>
	<xsl:import href="rules/rule_109.xsl"/>
	<xsl:import href="rules/rule_111.xsl"/>
	<!--
	-->
	<!-- book frontmatter -->
	<xsl:import href="rules/rule_201.xsl"/>
	<xsl:import href="rules/rule_202.xsl"/>
	<xsl:import href="rules/rule_203.xsl"/>
	<xsl:import href="rules/rule_204.xsl"/>
	<xsl:import href="rules/rule_205.xsl"/>
	<xsl:import href="rules/rule_206.xsl"/>
	<!--
	-->
	<!-- book part -->
	<xsl:import href="rules/rule_301.xsl"/>
	<xsl:import href="rules/rule_303.xsl"/>
	<xsl:import href="rules/rule_304.xsl"/>
	<xsl:import href="rules/rule_305.xsl"/>
	<xsl:import href="rules/rule_306.xsl"/>
	<xsl:import href="rules/rule_307.xsl"/>
	<xsl:import href="rules/rule_308.xsl"/>
	<xsl:import href="rules/rule_309.xsl"/>
	<xsl:import href="rules/rule_310.xsl"/>
	<xsl:import href="rules/rule_311.xsl"/>
	<xsl:import href="rules/rule_312.xsl"/>
	<xsl:import href="rules/rule_313.xsl"/>
	<xsl:import href="rules/rule_315.xsl"/>
	<xsl:import href="rules/rule_316.xsl"/>
	<xsl:import href="rules/rule_317.xsl"/>
	<xsl:import href="rules/rule_318.xsl"/>
	<xsl:import href="rules/rule_321.xsl"/>
	<!--
	-->
	<!-- general -->
	<xsl:import href="rules/rule_401.xsl"/>
	<xsl:import href="rules/rule_402.xsl"/>
	<xsl:import href="rules/rule_404.xsl"/>
	<xsl:import href="rules/rule_405.xsl"/>
	<xsl:import href="rules/rule_406.xsl"/>
	<xsl:import href="rules/rule_407.xsl"/>
	<xsl:import href="rules/rule_408.xsl"/>
	<xsl:import href="rules/rule_409.xsl"/>
	<xsl:import href="rules/rule_410.xsl"/>
	<xsl:import href="rules/rule_411.xsl"/>
	<xsl:import href="rules/rule_412.xsl"/>
	<xsl:import href="rules/rule_413.xsl"/>
	<xsl:import href="rules/rule_414.xsl"/>
	<xsl:import href="rules/rule_415.xsl"/>
	<xsl:import href="rules/rule_416.xsl"/>
	<xsl:import href="rules/rule_417.xsl"/>
	<xsl:import href="rules/rule_418.xsl"/>
	<xsl:import href="rules/rule_419.xsl"/>
	<xsl:import href="rules/rule_420.xsl"/>
	<xsl:import href="rules/rule_421.xsl"/>
	<xsl:import href="rules/rule_422.xsl"/>
	<xsl:import href="rules/rule_423.xsl"/>
	<xsl:import href="rules/rule_424.xsl"/>
	<xsl:import href="rules/rule_425.xsl"/>
	<xsl:import href="rules/rule_426.xsl"/>
	<xsl:import href="rules/rule_427.xsl"/>
	<xsl:import href="rules/rule_428.xsl"/>
	<xsl:import href="rules/rule_429.xsl"/>
	<xsl:import href="rules/rule_430.xsl"/>
	<xsl:import href="rules/rule_431.xsl"/>
	<xsl:import href="rules/rule_432.xsl"/>
	<xsl:import href="rules/rule_433.xsl"/>
	<xsl:import href="rules/rule_434.xsl"/>
	<xsl:import href="rules/rule_435.xsl"/>
	<xsl:import href="rules/rule_437.xsl"/>
	<xsl:import href="rules/rule_438.xsl"/>
	<xsl:import href="rules/rule_440.xsl"/>
	<xsl:import href="rules/rule_441.xsl"/>
	<xsl:import href="rules/rule_442.xsl"/>
	<xsl:import href="rules/rule_443.xsl"/>
	<xsl:import href="rules/rule_445.xsl"/>
	<xsl:import href="rules/rule_447.xsl"/>
	<xsl:import href="rules/rule_448.xsl"/>
	<xsl:import href="rules/rule_449.xsl"/>
	<xsl:import href="rules/rule_450.xsl"/>
	<xsl:import href="rules/rule_451.xsl"/>
	<xsl:import href="rules/rule_452.xsl"/>
	<xsl:import href="rules/rule_453.xsl"/>
	<xsl:import href="rules/rule_454.xsl"/>
	<xsl:import href="rules/rule_455.xsl"/>
	<xsl:import href="rules/rule_456.xsl"/>
	<xsl:import href="rules/rule_457.xsl"/>
	<!--
	-->
	<!-- cross-references -->
	<xsl:import href="rules/rule_501.xsl"/>
	<xsl:import href="rules/rule_502.xsl"/>
	<xsl:import href="rules/rule_504.xsl"/>
	<xsl:import href="rules/rule_505.xsl"/>
	<xsl:import href="rules/rule_506.xsl"/>
	<xsl:import href="rules/rule_507.xsl"/>
	<xsl:import href="rules/rule_508.xsl"/>
	<xsl:import href="rules/rule_509.xsl"/>
	<!--
	-->
	<!-- artwork -->
	<!--<xsl:import href="rules/rule_600.xsl"/>-->
	<!--<xsl:import href="rules/rule_601.xsl"/>-->
	<!--<xsl:import href="rules/rule_602.xsl"/>-->
	<!--<xsl:import href="rules/rule_603.xsl"/>-->
	<!--<xsl:import href="rules/rule_604.xsl"/>-->
	<xsl:import href="rules/rule_605.xsl"/>
	<xsl:import href="rules/rule_607.xsl"/>
	<xsl:import href="rules/rule_608.xsl"/>
	<!--
	-->
	<!-- tables -->
	<xsl:import href="rules/rule_620.xsl"/>
	<xsl:import href="rules/rule_621.xsl"/>
	<xsl:import href="rules/rule_622.xsl"/>
	<xsl:import href="rules/rule_623.xsl"/>
	<xsl:import href="rules/rule_624.xsl"/>
	<xsl:import href="rules/rule_625.xsl"/>
	<!--
	-->
	<!-- lists -->
	<xsl:import href="rules/rule_640.xsl"/>
	<xsl:import href="rules/rule_641.xsl"/>
	<xsl:import href="rules/rule_642.xsl"/>
	<xsl:import href="rules/rule_643.xsl"/>
	<!--
	-->
	<!-- extracts -->
	<xsl:import href="rules/rule_660.xsl"/>
	<xsl:import href="rules/rule_661.xsl"/>
	<!--
	-->
	<!-- dialogue -->
	<xsl:import href="rules/rule_680.xsl"/>
	<xsl:import href="rules/rule_681.xsl"/>
	<!--
	-->
	<!-- notes -->
	<xsl:import href="rules/rule_701.xsl"/>
	<xsl:import href="rules/rule_702.xsl"/>
	<xsl:import href="rules/rule_703.xsl"/>
	<xsl:import href="rules/rule_704.xsl"/>
	<xsl:import href="rules/rule_706.xsl"/>
	<!--
	-->
	<!-- references -->
	<xsl:import href="rules/rule_801.xsl"/>
	<xsl:import href="rules/rule_802.xsl"/>
	<xsl:import href="rules/rule_803.xsl"/>
	<xsl:import href="rules/rule_804.xsl"/>
	<xsl:import href="rules/rule_805.xsl"/>
	<xsl:import href="rules/rule_806.xsl"/>
	<xsl:import href="rules/rule_807.xsl"/>
	<xsl:import href="rules/rule_808.xsl"/>
	<xsl:import href="rules/rule_809.xsl"/>
	<xsl:import href="rules/rule_810.xsl"/>
	<xsl:import href="rules/rule_811.xsl"/>
	<xsl:import href="rules/rule_812.xsl"/>
	<xsl:import href="rules/rule_813.xsl"/>
	<xsl:import href="rules/rule_814.xsl"/>
	<xsl:import href="rules/rule_815.xsl"/>
	<xsl:import href="rules/rule_816.xsl"/>
	<xsl:import href="rules/rule_817.xsl"/>
	<xsl:import href="rules/rule_818.xsl"/>
	<xsl:import href="rules/rule_819.xsl"/>
	<xsl:import href="rules/rule_820.xsl"/>
	<xsl:import href="rules/rule_821.xsl"/>
	<xsl:import href="rules/rule_822.xsl"/>
	<xsl:import href="rules/rule_823.xsl"/>
	<xsl:import href="rules/rule_824.xsl"/>
	<xsl:import href="rules/rule_825.xsl"/>
	<xsl:import href="rules/rule_827.xsl"/>
	<xsl:import href="rules/rule_828.xsl"/>
	<xsl:import href="rules/rule_829.xsl"/>
	<xsl:import href="rules/rule_830.xsl"/>
	<xsl:import href="rules/rule_831.xsl"/>
	<xsl:import href="rules/rule_832.xsl"/>
	<xsl:import href="rules/rule_833.xsl"/>
	<xsl:import href="rules/rule_834.xsl"/>
	<xsl:import href="rules/rule_835.xsl"/>
	<xsl:import href="rules/rule_836.xsl"/>
	<xsl:import href="rules/rule_837.xsl"/>
	<xsl:import href="rules/rule_838.xsl"/>
	<xsl:import href="rules/rule_839.xsl"/>
	<xsl:import href="rules/rule_840.xsl"/>
	<xsl:import href="rules/rule_841.xsl"/>
	<xsl:import href="rules/rule_842.xsl"/>
	<!--
	-->
	<!-- index -->
	<!--
		<xsl:import href="rules/rule_901.xsl"/>
	<xsl:import href="rules/rule_902.xsl"/>
	<xsl:import href="rules/rule_903.xsl"/>
	<xsl:import href="rules/rule_904.xsl"/>
	<xsl:import href="rules/rule_905.xsl"/>
	<xsl:import href="rules/rule_906.xsl"/>
	<xsl:import href="rules/rule_907.xsl"/>
	<xsl:import href="rules/rule_908.xsl"/>-->
	<!--
	-->
	<!--<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>-->
</xsl:stylesheet>
