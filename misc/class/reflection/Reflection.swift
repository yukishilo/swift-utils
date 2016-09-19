import Foundation

class Reflection {
    /**
     * NOTE: does not work with computed properties like: var something:String{return ""}
     * NOTE: does not work with methods
     * NOTE: only works with regular variables
     * NOTE: some limitations with inheritance
     * NOTE: works with struct and class
     */
    static func reflect(instance:Any)->[(label:String,value:Any)]{
        var properties = [(label:String,value:Any)]()
        let mirror = Mirror(reflecting: instance)
        mirror.children.forEach{
            if let name = $0.label{/*label is actually optional comming from mirror, belive it or not*/
                properties.append((name,$0.value))
            }
        }
        return properties
    }
    /**
     * Converts an instance to XML
     * NOTE: This is a general solution for saving the state of a class/struct instance
     * EXAMPLE output:
     * <Selector>
     *     <id type=String>custom</id>
     *     <element type=String>Button</element>
     *     <classIds type=Array></classIds>
     *     <states type="Array">
     *         <item type=string>over</item>
     *         <item type=string>down</item>
     *     </states>
     * </Selector>
     */
    static func toXML(instance:Any)->XML{
        var xml:XML = XML()
        //find name of instance class
        let instanceName:String = String(instance.dynamicType)//if this doesnt work use generics
        //print(instanceName)
        xml.name = instanceName
        let properties = Reflection.reflect(instance)
        properties.forEach{
            if ($0.value is AnyArray){/*array*/
                Utils.handleArray(&xml,$0.value,$0.label)
            }else if (Utils.stringConvertiable($0.value)){/*all other values*///<-- must be convertible to string i guess
                Utils.handleBasicValue(&xml,$0.value,$0.label)
            }else{
                fatalError("unsuported type: " + "\($0.value.dynamicType)")
            }
        }
        return xml
    }
}
private class Utils{
    /**
     * Asserts if the PARAM value is a basic type
     */
    static func stringConvertiable(val:Any)->Bool{
        return val is Int || val is UInt || val is CGFloat || val is String || val is Double || val is Float || val is Bool
    }
    /**
     * Basic value types
     */
    static func handleBasicValue(inout theXML:XML,_ value:Any,_ name:String){
        Swift.print("handleBasicValue:" + " name \(name)" + "value: \(value)" )
        let child = XML()
        child.name = name
        child["type"] = String(value.dynamicType)
        let string:String = String(value)
        child.stringValue = string/*add value*/
        theXML.appendChild(child)
    }
    /**
     * Array types
     */
    static func handleArray(inout theXML:XML,_ value:Any,_ name:String){
        Swift.print("handleArray: " + "name \(name)" + "$0.value: \(value)" )
        var arrayXML = XML()
        arrayXML.name = name
        arrayXML["type"] = "Array"
        let properties = Reflection.reflect(value)
        properties.forEach{
            if (stringConvertiable($0.value)){/*<--asserts if the value can be converted to a string*/
                handleBasicValue(&arrayXML,$0.value,"item")
            }else if($0.value is AnyArray){/*array*/
                handleArray(&arrayXML,$0.value,$0.label)
            }else{
                fatalError("unsuported type: " + "\($0.value.dynamicType)")
            }
        }
        theXML.appendChild(arrayXML)
    }
}