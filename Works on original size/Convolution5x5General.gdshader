shader_type canvas_item;

//convolution matrix definitions.	{1.0,0.0,1.0,  0.0,1.0,0.0,  1.0,0.0,1.0}


const int cm_size = 5;
const float cm_weights[25] = 
{
1.0,1.0,1.0,1.0,1.0,
1.0,1.0,1.0,1.0,1.0, 
1.0,1.0,1.0,1.0,1.0,
1.0,1.0,1.0,1.0,1.0,  
1.0,1.0,1.0,1.0,1.0
};
/*
const int cm_size = 3;
const float cm_weights[9] = 
{
1.0,1.0,1.0,
1.0,1.0,1.0,  
1.0,1.0,1.0
};
*/
void fragment() {
	//sample offset to sample from middle
	vec2 pixel_half_size = TEXTURE_PIXEL_SIZE/2.0;
	//color candidate and the amount of times a colour occured in sampled area
	vec4 col = vec4(0.0);
	int col_n = 1; 
	
	for(int _height = 0; _height < cm_size; _height++){
		for(int _width = 0; _width < cm_size; _width++){
			bool _biased_sample = (_height == 0) && (_width == 0);
			
			int i_width = cm_size - _width ; //inverse width
			int i_height = cm_size - _height ; //inverse height
			//switches sign on even number so the sampling order is 2,-2,1,-1,0
			float coef_x = 1.0;
			float coef_y = 1.0;
			if(i_width % 2 != 0){
				coef_x = -1.0;
			}
			if(i_height % 2 != 0){
				coef_y = -1.0;
			}
			//centers the sampling kernel
			float _tx = float((i_width - i_width % 2)) * coef_x / 2.0;
			float _ty = float((i_height - i_height % 2)) * coef_y / 2.0;
			//assembles UV sample vector
			float w_tx = TEXTURE_PIXEL_SIZE.x * _tx / float(cm_size) + UV.x + pixel_half_size.x / float(cm_size);
			float w_ty = TEXTURE_PIXEL_SIZE.y * _ty / float(cm_size) + UV.y + pixel_half_size.y / float(cm_size);
			
			/* //Sampling with posterized UV
			float w_tx = TEXTURE_PIXEL_SIZE.x * _tx + floor(UV.x / TEXTURE_PIXEL_SIZE.x) * TEXTURE_PIXEL_SIZE.x + pixel_half_size.x;
			float w_ty = TEXTURE_PIXEL_SIZE.y * _ty + floor(UV.y / TEXTURE_PIXEL_SIZE.y) * TEXTURE_PIXEL_SIZE.y + pixel_half_size.y;
			*/
			//makes sure it doesnt go oob
			w_tx = clamp(w_tx,0.0,1.0);
			w_ty = clamp(w_ty,0.0,1.0);
			vec2 s_uv = vec2(w_tx,w_ty);
			//index for check for convolution weight in weight matrix and centers the sample of the weights from convolution matrix
			int convolution_sample =int(floor(float(cm_size*cm_size)/2.0))  + int(_tx) + int(_ty)*3;
			//pre-sample weight
		if(_biased_sample){
					col = texture(TEXTURE,UV);
					col_n = 0;
			}
			//actual color sampling
			if(cm_weights[convolution_sample] != 0.0){
				vec4 t_cl = texture(TEXTURE,s_uv);//temporary color sample
				
				//choosing final color candidate
				if(col == t_cl){
					col_n += int(cm_weights[convolution_sample]);
				}else{
					if(col_n - int(cm_weights[convolution_sample]) >= 0){
						col_n -= int(cm_weights[convolution_sample]);
					}
					else{
						col = t_cl;//vec4(vec3(0.0),1.0);//
						col_n = 0;
					}
				}
			}
		}
	}
	//displaying final colour candidate
	COLOR = col;
}
