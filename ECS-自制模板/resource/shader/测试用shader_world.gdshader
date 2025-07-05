shader_type canvas_item;
//Render mode set to using global scene coordinates
render_mode world_vertex_coords;

uniform vec2 offsetPos;
uniform float distances = 10.;
uniform bool enableHiding = false;

//Preparing varyings to use between function

varying vec4 pos;
varying mat4 canvasMatrix;

void vertex() {
	//Save the origin point coordinates of the Node2D, in GLOBAL COORDINATES
	pos = vec4(VERTEX, 0.0, 0.0);
	//Save the matrix that transforms coordinates from GLOBAL to CANVAS
	canvasMatrix = MODEL_MATRIX;

	pos.x -= offsetPos.x;
	pos.y -= offsetPos.y;
}

void fragment() {
	//The width of the camera in editor pixels (set this manually)
	float cameraWidth = 800.0;
	//Calculate the ratio by which editor pixels are divided in the CANVAS
	float resizeRatio = SCREEN_PIXEL_SIZE.x*cameraWidth;
	//Convert the origin point vector from GLOBAL to CANVAS coordinates
	vec4 screenspaceVector = canvasMatrix * pos;
	//Resize the new vector by the resize ratio
	vec4 globalPos = resizeRatio * screenspaceVector;
	//The conversion is complete. globalPos now indicates the position
	//of the currently evaluated pixel in the fragment() function, in global
	//coordinates. It can also be compared to other vectors in global coordinates,
	//without the need to convert them.

	//In this example, a red circle with a diameter of 5px will be rendered
	//on top of this sprite, with a center at (0,0)

	vec4 origin_color = texture(TEXTURE, UV);
	if(
		distance(globalPos, vec4(0.0, 0.0, 0.0, 1.0)) < distances
	){
		if (enableHiding)
			COLOR = vec4(origin_color.xyz, smoothstep(0.,distances, distance(globalPos, vec4(0.0, 0.0, 0.0, 1.0))));
		else
			COLOR = origin_color;
	}
}