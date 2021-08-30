var edi_parser = require("/custom-modules/custom/edi-parser/edi-parser-xml.xqy");

/* The below stylesheet removes all the namespaces */ 
var styleSheetToRemoveNS = fn.head(xdmp.unquote('<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> \
                                                <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/> \
                                                <!-- keep comments -->\
                                                <xsl:template match="comment()">\
                                                    <xsl:copy>\
                                                    <xsl:apply-templates/>\
                                                    </xsl:copy>\
                                                </xsl:template>\
                                                <xsl:template match="*">\
                                                    <!-- remove element prefix -->\
                                                    <xsl:element name="{local-name()}">\
                                                    <!-- process attributes -->\
                                                    <xsl:for-each select="@*">\
                                                        <!-- remove attribute prefix -->\
                                                        <xsl:attribute name="{local-name()}">\
                                                        <xsl:value-of select="."/>\
                                                        </xsl:attribute>\
                                                    </xsl:for-each>\
                                                    <xsl:apply-templates/>\
                                                    </xsl:element>\
                                                </xsl:template>\
                                                </xsl:stylesheet>'
                                                )
                                    )

function applyTransform (context,content,config) {
    var styleSheetToAddDesc = fn.head(xdmp.unquote('<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> \
                                                    <xsl:strip-space elements="*"/> \
                                                    <xsl:output omit-xml-declaration="yes" indent="yes" method="xml" /> \
                                                    <xsl:variable name="transformations" select= "doc(\'' + config.dictionary + '\')" /> \
                                                    <xsl:template match="@*|node()">  \
                                                        <xsl:copy> \
                                                        <xsl:apply-templates select="@*|node()" /> \
                                                        </xsl:copy> \
                                                    </xsl:template> \
                                                    <xsl:template match="*:segment-identifier"> \
                                                        <xsl:variable name="cur" select="text()" /> \
                                                        <xsl:copy> \
                                                        <xsl:attribute name="DESC"> \
                                                        <xsl:value-of select="$transformations/edi-404/dict[@Segment=$cur]/@Description" />\
                                                        </xsl:attribute> \
                                                        <xsl:apply-templates select="node()"/> \
                                                        </xsl:copy> \
                                                    </xsl:template> \
                                                    </xsl:stylesheet>'
                                                    )
                                        );
    raw_doc_uri = context.uri.replace("xml","txt");
    xdmp.documentInsert(raw_doc_uri, content, {permissions : [xdmp.permission('data-hub-common', 'read'),
                                                              xdmp.permission('data-hub-common','update')
                                                             ],
                                               collections : "edi-raw-404"
                                              });
    var new_content = edi_parser.ediToXml(content,
                                        config.ediSegmentDelimiter,
                                        config.ediFieldDelimiter,
                                        config.ediComponentDelimiter,
                                        null,
                                        fn.false()
                                        )
    if (config.removeNS.toUpperCase() == "TRUE") {
        if (config.dictionary == "NA") {
            return xdmp.xsltEval(styleSheetToRemoveNS,new_content);
        }
        else {
            return xdmp.xsltEval(styleSheetToAddDesc,xdmp.xsltEval(styleSheetToRemoveNS,new_content));
        }
    }
    else {
        if (config.dictionary == "NA") {    
            return new_content;
        }
        else {
            return xdmp.xsltEval(styleSheetToAddDesc,new_content);
        }
    }
    
}
function EDI404Transform(context, params, content) {
    
    var config = {
        removeNS : "false",
        dictionary : "",
        ediSegmentDelimiter : "~",
        ediFieldDelimiter : "*",
        ediComponentDelimiter : ":"
    }
    config.removeNS = params.removeNS ? params.removeNS : 'false';
    config.ediSegmentDelimiter = params.ediSegmentDelimiter ? params.ediSegmentDelimiter : '~';
    config.ediFieldDelimiter = params.ediFieldDelimiter ? params.ediFieldDelimiter : '*';
    config.ediComponentDelimiter = params.ediComponentDelimiter ? params.ediComponentDelimiter : ':';
    config.dictionary = params.dictionary ? params.dictionary : 'NA';
    return applyTransform(context,content,config)
}
exports.transform=EDI404Transform