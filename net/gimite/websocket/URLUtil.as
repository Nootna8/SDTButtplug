////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package net.gimite.websocket
{
    
    /**
     *  The URLUtil class is a static class with methods for working with
     *  full and relative URLs within Flex.
     *  
     *  @see mx.managers.BrowserManager
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public class URLUtil
    {
        //--------------------------------------------------------------------------
        //
        // Private Static Constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private 
         */
        private static const SQUARE_BRACKET_LEFT:String = "]";
        private static const SQUARE_BRACKET_RIGHT:String = "[";
        private static const SQUARE_BRACKET_LEFT_ENCODED:String = encodeURIComponent(SQUARE_BRACKET_LEFT);
        private static const SQUARE_BRACKET_RIGHT_ENCODED:String = encodeURIComponent(SQUARE_BRACKET_RIGHT);
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        /**
         *  @private
         */
        public function URLUtil()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Returns the domain and port information from the specified URL.
         *  
         *  @param url The URL to analyze.
         *  @return The server name and port of the specified URL.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function getServerNameWithPort(url:String):String
        {
            // Find first slash; second is +1, start 1 after.
            var start:int = url.indexOf("/") + 2;
            var length:int = url.indexOf("/", start);
            return length == -1 ? url.substring(start) : url.substring(start, length);
        }
        
        /**
         *  Returns the server name from the specified URL.
         *  
         *  @param url The URL to analyze.
         *  @return The server name of the specified URL.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function getServerName(url:String):String
        {
            var sp:String = getServerNameWithPort(url);
            
            // If IPv6 is in use, start looking after the square bracket.
            var delim:int = URLUtil.indexOfLeftSquareBracket(sp);
            delim = (delim > -1)? sp.indexOf(":", delim) : sp.indexOf(":");   
            
            if (delim > 0)
                sp = sp.substring(0, delim);
            return sp;
        }
        
        /**
         *  Returns the port number from the specified URL.
         *  
         *  @param url The URL to analyze.
         *  @return The port number of the specified URL.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function getPort(url:String):uint
        {
            var sp:String = getServerNameWithPort(url);
            // If IPv6 is in use, start looking after the square bracket.
            var delim:int = URLUtil.indexOfLeftSquareBracket(sp);
            delim = (delim > -1)? sp.indexOf(":", delim) : sp.indexOf(":");          
            var port:uint = 0;
            if (delim > 0)
            {
                var p:Number = Number(sp.substring(delim + 1));
                if (!isNaN(p))
                    port = int(p);
            }
            
            return port;
        }
        
        /**
         *  Converts a potentially relative URL to a fully-qualified URL.
         *  If the URL is not relative, it is returned as is.
         *  If the URL starts with a slash, the host and port
         *  from the root URL are prepended.
         *  Otherwise, the host, port, and path are prepended.
         *
         *  @param rootURL URL used to resolve the URL specified by the <code>url</code> parameter, if <code>url</code> is relative.
         *  @param url URL to convert.
         *
         *  @return Fully-qualified URL.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function getFullURL(rootURL:String, url:String):String
        {
            if (url != null && !URLUtil.isHttpURL(url))
            {
                if (url.indexOf("./") == 0)
                {
                    url = url.substring(2);
                }
                if (URLUtil.isHttpURL(rootURL))
                {
                    var slashPos:Number;
                    
                    if (url.charAt(0) == '/')
                    {
                        // non-relative path, "/dev/foo.bar".
                        slashPos = rootURL.indexOf("/", 8);
                        if (slashPos == -1)
                            slashPos = rootURL.length;
                    }
                    else
                    {
                        // relative path, "dev/foo.bar".
                        slashPos = rootURL.lastIndexOf("/") + 1;
                        if (slashPos <= 8)
                        {
                            rootURL += "/";
                            slashPos = rootURL.length;
                        }
                    }
                    
                    if (slashPos > 0)
                        url = rootURL.substring(0, slashPos) + url;
                }
            }
            
            return url;
        }
        
        // Note: The following code was copied from Flash Remoting's
        // NetServices client components.
        // It is reproduced here to keep the services APIs
        // independent of the deprecated NetServices code.
        // Note that it capitalizes any use of URL in method or class names.
        
        /**
         *  Determines if the URL uses the HTTP, HTTPS, or RTMP protocol. 
         *
         *  @param url The URL to analyze.
         * 
         *  @return <code>true</code> if the URL starts with "http://", "https://", or "rtmp://".
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function isHttpURL(url:String):Boolean
        {
            return url != null &&
                (url.indexOf("http://") == 0 ||
                    url.indexOf("https://") == 0);
        }
        
        /**
         *  Determines if the URL uses the secure HTTPS protocol. 
         *
         *  @param url The URL to analyze.
         * 
         *  @return <code>true</code> if the URL starts with "https://".
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function isHttpsURL(url:String):Boolean
        {
            return url != null && url.indexOf("https://") == 0;
        }
        
        /**
         *  Returns the protocol section of the specified URL.
         *  The following examples show what is returned based on different URLs:
         *  
         *  <pre>
         *  getProtocol("https://localhost:2700/") returns "https"
         *  getProtocol("rtmp://www.myCompany.com/myMainDirectory/groupChatApp/HelpDesk") returns "rtmp"
         *  getProtocol("rtmpt:/sharedWhiteboardApp/June2002") returns "rtmpt"
         *  getProtocol("rtmp::1234/chatApp/room_name") returns "rtmp"
         *  </pre>
         *
         *  @param url String containing the URL to parse.
         *
         *  @return The protocol or an empty String if no protocol is specified.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function getProtocol(url:String):String
        {
            var slash:int = url.indexOf("/");
            var indx:int = url.indexOf(":/");
            if (indx > -1 && indx < slash)
            {
                return url.substring(0, indx);
            }
            else
            {
                indx = url.indexOf("::");
                if (indx > -1 && indx < slash)
                    return url.substring(0, indx);
            }
            
            return "";
        }
        
        /**
         *  Replaces the protocol of the
         *  specified URI with the given protocol.
         *
         *  @param uri String containing the URI in which the protocol
         *  needs to be replaced.
         *
         *  @param newProtocol String containing the new protocol to use.
         *
         *  @return The URI with the protocol replaced,
         *  or an empty String if the URI does not contain a protocol.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function replaceProtocol(uri:String,
                                               newProtocol:String):String
        {
            return uri.replace(getProtocol(uri), newProtocol);
        }
        
        /**
         *  Returns a new String with the port replaced with the specified port.
         *  If there is no port in the specified URI, the port is inserted.
         *  This method expects that a protocol has been specified within the URI.
         *
         *  @param uri String containing the URI in which the port is replaced.
         *  @param newPort uint containing the new port to subsitute.
         *
         *  @return The URI with the new port.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function replacePort(uri:String, newPort:uint):String
        {
            var result:String = "";
            
            // First, determine if IPv6 is in use by looking for square bracket
            var indx:int = uri.indexOf("]");
            
            // If IPv6 is not in use, reset indx to the first colon
            if (indx == -1)
                indx = uri.indexOf(":");
            
            var portStart:int = uri.indexOf(":", indx+1);
            var portEnd:int;
            
            // If we have a port
            if (portStart > -1)
            {
                portStart++; // move past the ":"
                portEnd = uri.indexOf("/", portStart);
                //@TODO: need to throw an invalid uri here if no slash was found
                result = uri.substring(0, portStart) +
                    newPort.toString() +
                    uri.substring(portEnd, uri.length);
            }
            else
            {
                // Insert the specified port
                portEnd = uri.indexOf("/", indx);
                if (portEnd > -1)
                {
                    // Look to see if we have protocol://host:port/
                    // if not then we must have protocol:/relative-path
                    if (uri.charAt(portEnd+1) == "/")
                        portEnd = uri.indexOf("/", portEnd + 2);
                    
                    if (portEnd > 0)
                    {
                        result = uri.substring(0, portEnd) +
                            ":"+ newPort.toString() +
                            uri.substring(portEnd, uri.length);
                    }
                    else
                    {
                        result = uri + ":" + newPort.toString();
                    }
                }
                else
                {
                    result = uri + ":"+ newPort.toString();
                }
            }
            
            return result;
        }
        
        /**
         * Tests whether two URI Strings are equivalent, ignoring case and
         * differences in trailing slashes.
         * 
         *  @param uri1 The first URI to compare.
         *  @param uri2 The second URI to compare.
         *  
         *  @return <code>true</code> if the URIs are equal. Otherwise, <code>false</code>.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function urisEqual(uri1:String, uri2:String):Boolean
        {
            if (uri1 != null && uri2 != null)
            {
                uri1 = StringUtil.trim(uri1).toLowerCase();
                uri2 = StringUtil.trim(uri2).toLowerCase();
                
                if (uri1.charAt(uri1.length - 1) != "/")
                    uri1 = uri1 + "/";
                
                if (uri2.charAt(uri2.length - 1) != "/")
                    uri2 = uri2 + "/";
            }
            
            return uri1 == uri2;
        }
        
        /**
         *  Given a url, determines whether the url contains the server.name and
         *  server.port tokens.
         *
         *  @param url A url string. 
         * 
         *  @return <code>true</code> if the url contains server.name and server.port tokens.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */ 
        public static function hasTokens(url:String):Boolean
        {
            if (url == null || url == "")
                return false;
            if (url.indexOf(SERVER_NAME_TOKEN) > 0)
                return true;
            if (url.indexOf(SERVER_PORT_TOKEN) > 0)
                return true;
            return false;
        }
        
        /**
         *  The pattern in the String that is passed to the <code>replaceTokens()</code> method that 
         *  is replaced by the application's server name.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static const SERVER_NAME_TOKEN:String = "{server.name}";
        
        /**
         *  The pattern in the String that is passed to the <code>replaceTokens()</code> method that 
         *  is replaced by the application's port.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static const SERVER_PORT_TOKEN:String = "{server.port}";
        
        /**
         *  Enumerates an object's dynamic properties (by using a <code>for..in</code> loop)
         *  and returns a String. You typically use this method to convert an ActionScript object to a String that you then append to the end of a URL.
         *  By default, invalid URL characters are URL-encoded (converted to the <code>%XX</code> format).
         *
         *  <p>For example:
         *  <pre>
         *  var o:Object = { name: "Alex", age: 21 };
         *  var s:String = URLUtil.objectToString(o,";",true);
         *  trace(s);
         *  </pre>
         *  Prints "name=Alex;age=21" to the trace log.
         *  </p>
         *  
         *  @param object The object to convert to a String.
         *  @param separator The character that separates each of the object's <code>property:value</code> pair in the String.
         *  @param encodeURL Whether or not to URL-encode the String.
         *  
         *  @return The object that was passed to the method.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function objectToString(object:Object, separator:String=';',
                                              encodeURL:Boolean = true):String
        {
            var s:String = internalObjectToString(object, separator, null, encodeURL);
            return s;
        }
        
        private static function indexOfLeftSquareBracket(value:String):int
        {
            var delim:int = value.indexOf(SQUARE_BRACKET_LEFT);
            if (delim == -1)
                delim = value.indexOf(SQUARE_BRACKET_LEFT_ENCODED);
            return delim;
        }
        
        private static function internalObjectToString(object:Object, separator:String, prefix:String, encodeURL:Boolean):String
        {
            var s:String = "";
            var first:Boolean = true;
            
            for (var p:String in object)
            {
                if (first)
                {
                    first = false;
                }
                else
                    s += separator;
                
                var value:Object = object[p];
                var name:String = prefix ? prefix + "." + p : p;
                if (encodeURL)
                    name = encodeURIComponent(name);
                
                if (value is String)
                {
                    s += name + '=' + (encodeURL ? encodeURIComponent(value as String) : value);
                }
                else if (value is Number)
                {
                    value = value.toString();
                    if (encodeURL)
                        value = encodeURIComponent(value as String);
                    
                    s += name + '=' + value;
                }
                else if (value is Boolean)
                {
                    s += name + '=' + (value ? "true" : "false");
                }
                else
                {
                    if (value is Array)
                    {
                        s += internalArrayToString(value as Array, separator, name, encodeURL);
                    }
                    else // object
                    {
                        s += internalObjectToString(value, separator, name, encodeURL);
                    }
                }
            }
            return s;
        }
        
        private static function replaceEncodedSquareBrackets(value:String):String
        {
            var rightIndex:int = value.indexOf(SQUARE_BRACKET_RIGHT_ENCODED);
            if (rightIndex > -1)
            {
                value = value.replace(SQUARE_BRACKET_RIGHT_ENCODED, SQUARE_BRACKET_RIGHT);
                var leftIndex:int = value.indexOf(SQUARE_BRACKET_LEFT_ENCODED);
                if (leftIndex > -1)
                    value = value.replace(SQUARE_BRACKET_LEFT_ENCODED, SQUARE_BRACKET_LEFT);
            }
            return value;
        }
        
        private static function internalArrayToString(array:Array, separator:String, prefix:String, encodeURL:Boolean):String
        {
            var s:String = "";
            var first:Boolean = true;
            
            var n:int = array.length;
            for (var i:int = 0; i < n; i++)
            {
                if (first)
                {
                    first = false;
                }
                else
                    s += separator;
                
                var value:Object = array[i];
                var name:String = prefix + "." + i;
                if (encodeURL)
                    name = encodeURIComponent(name);
                
                if (value is String)
                {
                    s += name + '=' + (encodeURL ? encodeURIComponent(value as String) : value);
                }
                else if (value is Number)
                {
                    value = value.toString();
                    if (encodeURL)
                        value = encodeURIComponent(value as String);
                    
                    s += name + '=' + value;
                }
                else if (value is Boolean)
                {
                    s += name + '=' + (value ? "true" : "false");
                }
                else
                {
                    if (value is Array)
                    {
                        s += internalArrayToString(value as Array, separator, name, encodeURL);
                    }
                    else // object
                    {
                        s += internalObjectToString(value, separator, name, encodeURL);
                    }
                }
            }
            return s;
        }
        
        
        // Reusable reg-exp for token replacement. The . means any char, so this means
        // we should handle server.name and server-name, etc...
        private static const SERVER_NAME_REGEX:RegExp = new RegExp("\\{server.name\\}", "g");
        private static const SERVER_PORT_REGEX:RegExp = new RegExp("\\{server.port\\}", "g");    
    }
    
}