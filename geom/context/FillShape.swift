import Foundation

class FillShape :Shape{
    var fillStyle:IFillStyle?;
    
        
    
    override func drawInContext(ctx: CGContext) {
        Swift.print("FillShape.drawInContext")
        graphics.context = ctx
        
        //TODO:you only need to call the draw method from here
        
        self.graphics.fill(fillStyle!.color)//Stylize the fill
        self.graphics.draw(path)//draw everything
        
    }
}
