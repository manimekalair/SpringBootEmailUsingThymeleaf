(:
XML Query Use Cases: http://www.w3.org/TR/xquery-use-cases/
Copyright ©2003 World Wide Web Consortium, (Massachusetts Institute of Technology, European Research Consortium for Informatics and Mathematics, Keio University). All Rights Reserved. This work is distributed under the W3C® Software License [1] in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
[1] http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
:)
(:
 Filename: strongQ11_callingfunction.xq 
 Section:   1.9.4.11 Q11  
 Purpose:  Here is a query that calls the function strongQ11.xq to get the total for  an invoice (before calculating taxes and shipping charges). 
 :)

(: This query illustrates the need to be able to pass a sequence as a  parameter to a function. :)
(: If the input document contains a purchase order  for the given date and person, a total will be computed for each invoice :)

declare namespace ipo   = "http://www.example.com/IPO";
import module  namespace calc =  "http://www.example.com/calc" at "strongQ11.xq";

for $p in doc("ipo.xml")//element(ipo:purchaseOrder)
where $p/shipTo/name="Helen Zoe"
   and $p/@orderDate = xs:date("1999-12-01")
return( "Quantity: ", calc:quantity  ($p//item)," Price: ", calc:price($p//item)," Total: ", calc:total-price($p//item))
 































