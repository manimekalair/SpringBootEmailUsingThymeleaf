(:
XML Query Use Cases: http://www.w3.org/TR/xquery-use-cases/
Copyright ©2003 World Wide Web Consortium, (Massachusetts Institute of Technology, European Research Consortium for Informatics and Mathematics, Keio University). All Rights Reserved. This work is distributed under the W3C® Software License [1] in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
[1] http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
:)
(:
 Filename: strongQ11.xq 
 Section:   1.9.4.11 Q11  
 Purpose:  Write a function that computes the total price  for a sequence of item elements. :)


module namespace c="http://www.example.com/calc" ;
declare namespace ipo="http://www.example.com/IPO";

declare function c:total-price( $i as element()* )
  as xs:decimal
  {
  let $subtotals := for $s in $i return $s/quantity * $s/USPrice
   return sum( $subtotals )cast as xs:decimal
   }; 
declare function c:quantity( $i as element()* )
  as xs:decimal
  {
  $i/quantity cast as xs:decimal
   }; 

declare function c:price( $i as element()* )
  as xs:decimal
  {
  $i/USPrice cast as xs:decimal
   }; 







































