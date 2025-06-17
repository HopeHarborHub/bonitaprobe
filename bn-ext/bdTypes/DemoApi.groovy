package org.demo.api

import groovy.sql.Sql
import org.bonitasoft.web.extension.rest.RestApiController
import org.bonitasoft.web.extension.rest.RestApiResponse
import org.bonitasoft.web.extension.rest.RestApiResponseBuilder
import org.bonitasoft.web.extension.rest.RestAPIContext
import javax.servlet.http.HttpServletRequest
import javax.naming.Context
import javax.naming.InitialContext
import javax.sql.DataSource
import java.util.zip.ZipInputStream

@SuppressWarnings('unused')
class DemoApi implements RestApiController {

    static String query = $/
        select content as bdm_content from tenant_resource tr
        where tr."state" = 'INSTALLED' order by tr.lastUpdateDate desc limit 1
        /$.stripIndent().trim()

    private static List extractBusinessObjects(String xmlContent) {
        def parser = new XmlSlurper()
        parser.setFeature("http://apache.org/xml/features/disallow-doctype-decl", false)
        parser.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)
        def xml = parser.parseText(xmlContent)
        def businessObjects = xml.declareNamespace('': 'http://documentation.bonitasoft.com/bdm-xml-schema/1.0')
        return businessObjects.businessObjects.businessObject.collect { bo -> bo.@qualifiedName.text() }
    }

    @Override
    RestApiResponse doHandle(HttpServletRequest request, RestApiResponseBuilder responseBuilder, RestAPIContext context) {
        try {
            String result
            Context ctx = new InitialContext()
            DataSource dataSource = (DataSource) ctx.lookup("java:/comp/env/bonitaDS")
            def sql = new Sql(dataSource)
            try {
                def row = sql.firstRow(query)
                if (row) {
                    def content = row.bdm_content
                    def bis = new ByteArrayInputStream(content)
                    def zis = new ZipInputStream(bis)
                    try {
                        def entry
                        while ((entry = zis.nextEntry) != null) {
                            if (entry.name == "bom.zip") {
                                def baos = new ByteArrayOutputStream()
                                byte[] buffer = new byte[1024]
                                int len
                                while ((len = zis.read(buffer)) > 0) {
                                    baos.write(buffer, 0, len)
                                }
                                def bomZipBytes = baos.toByteArray()
                                def bomBis = new ByteArrayInputStream(bomZipBytes)
                                def bomZis = new ZipInputStream(bomBis)
                                try {
                                    def bomEntry
                                    while ((bomEntry = bomZis.nextEntry) != null) {
                                        if (bomEntry.name == "bom.xml") {
                                            baos = new ByteArrayOutputStream()
                                            while ((len = bomZis.read(buffer)) > 0) {
                                                baos.write(buffer, 0, len)
                                            }
                                            def xmlContent = new String(baos.toByteArray(), "UTF-8")
                                            def businessObjects = extractBusinessObjects(xmlContent)
                                            result = businessObjects.join('\n')
                                            break
                                        }
                                    }
                                } finally {
                                    bomZis.close()
                                    bomBis.close()
                                }
                                break
                            }
                        }
                    } finally {
                        zis.close()
                        bis.close()
                    }
                } else {
                    result = "No installed BDM found"
                }
            } finally {
                sql.close()
            }
            return responseBuilder.with {
                withResponseStatus(200)
                withMediaType("text/plain")
                withResponse(result.toString())
                build()
            }
        } catch (Exception e) {
            return responseBuilder.with {
                withResponseStatus(500)
                withMediaType("text/plain")
                withResponse("Error: ${e.message}\nStack: ${e.stackTrace.join('\n')}")
                build()
            }
        }
    }
}