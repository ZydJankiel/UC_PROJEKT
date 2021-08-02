module OBSTACLES (
    input wire clk,
    input wire rst,
    input wire [11:0] hcount_in,
    input wire hblnk_in,
    input wire hsync_in,
    input wire [11:0] vcount_in,
    input wire vblnk_in,
    input wire vsync_in,
    input wire [11:0] rgb_in,
    input wire [11:0] xpos,
    input wire [11:0] ypos,
    input wire game_on,
    input wire menu_on,
    input wire victory,
    input wire play_selected,
    
    output wire [15:0] obstacles_counted,
    output wire [27:0] delayed_signals,
    output wire [35:0] obstacle_data
);

wire [35:0] mux_out;
wire [27:0] delayed_signals_out;

wire [15:0] obstacles_counted_out;

wire [11:0] rgb_out_obs0, rgb_out_obs1, rgb_out_obs2, rgb_out_obs3, rgb_out_obs4, rgb_out_obs5, rgb_out_obs6, rgb_out_obs7;
wire [11:0] obstacle0_x_out,obstacle0_y_out, obstacle1_x_out, obstacle1_y_out, obstacle2_x_out, obstacle2_y_out, obstacle3_x_out, obstacle3_y_out;
wire [11:0] obstacle4_x_out,obstacle4_y_out, obstacle5_x_out, obstacle5_y_out, obstacle6_x_out, obstacle6_y_out, obstacle7_x_out, obstacle7_y_out;
wire [3:0] selected_obstacle;

wire done_obs0, done_obs1, done_obs2, done_obs3, done_obs4, done_obs5, done_obs6, done_obs7, done_control, done_counter;

pillars_horizontal_obstacle #(.SELECT_CODE(4'b0000)) pillars_horizontal_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle0_x_out),
    .obstacle_y(obstacle0_y_out),
    .rgb_out(rgb_out_obs0),
    .done(done_obs0)
);

lasers_obstacle vertical_lasers_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle1_x_out),
    .obstacle_y(obstacle1_y_out),
    .rgb_out(rgb_out_obs1),
    .done(done_obs1) 
);

horizontal_lasers_obstacle horizontal_lasers_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle2_x_out),
    .obstacle_y(obstacle2_y_out),
    .rgb_out(rgb_out_obs2),
    .done(done_obs2)
);

square_follow_obstacle square_follow_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle3_x_out),
    .obstacle_y(obstacle3_y_out),
    .rgb_out(rgb_out_obs3),
    .done(done_obs3)
);

mouse_follower_obstacle mouse_follower_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    .mouse_xpos(xpos),
    .mouse_ypos(ypos),

    //outputs  
    .obstacle_x(obstacle4_x_out),
    .obstacle_y(obstacle4_y_out),
    .rgb_out(rgb_out_obs4),
    .done(done_obs4) 
);

falling_spikes_obstacle falling_spikes_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    .mouse_xpos(xpos),
    //.mouse_ypos(ypos),
    
    //outputs  
    .obstacle_x(obstacle5_x_out),
    .obstacle_y(obstacle5_y_out),
    .rgb_out(rgb_out_obs5),
    .done(done_obs5)
);

obstacle1 #( .TEST_TOP_LINE(500),
             .TEST_BOTTOM_LINE(400),
             .TEST_LEFT_LINE(520), 
             .TEST_RIGHT_LINE(620),
             .COLOR(12'h0_f_f),
             .SELECT_CODE(4'b0110) ) rectangle6_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle6_x_out),
    .obstacle_y(obstacle6_y_out),
    .rgb_out(rgb_out_obs6),
    .done(done_obs6) 
);

obstacle1 #( .TEST_TOP_LINE(500),
             .TEST_BOTTOM_LINE(400),
             .TEST_LEFT_LINE(400), 
             .TEST_RIGHT_LINE(500),
             .COLOR(12'h0_f_0),
             .SELECT_CODE(4'b0111) ) rectangle7_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .game_on(game_on),
    .menu_on(menu_on),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    
    //outputs  
    .obstacle_x(obstacle7_x_out),
    .obstacle_y(obstacle7_y_out),
    .rgb_out(rgb_out_obs7),
    .done(done_obs7) 
);

obstacles_counter obstacles_counter (
    //inputs
    .clk(clk),
    .rst(rst),
    .start(play_selected),
    .done_in(done_control),
    
    //outputs
    .done_out(done_counter),
    .obstacles_counted(obstacles_counted_out)
);

obstacles_control obstacles_control (
    //inputs
    .clk(clk),
    .rst(rst),
    .done(victory || done_obs0 || done_obs1 || done_obs2 || done_obs3 || done_obs4 || done_obs5 || done_obs6 || done_obs7),
    .play_selected(play_selected),
    
    //outputs
    .obstacle_code(selected_obstacle),
    .done_out(done_control)
);

obstacle_mux_16_to_1 obstacle_mux_16_to_1 (
    //inputs
    .input_0({obstacle0_x_out,obstacle0_y_out,rgb_out_obs0}),
    .input_1({obstacle1_x_out,obstacle1_y_out,rgb_out_obs1}),
    .input_2({obstacle2_x_out,obstacle2_y_out,rgb_out_obs2}),
    .input_3({obstacle3_x_out,obstacle3_y_out,rgb_out_obs3}),
    .input_4({obstacle4_x_out,obstacle4_y_out,rgb_out_obs4}),
    .input_5({obstacle5_x_out,obstacle5_y_out,rgb_out_obs5}),
    .input_6({obstacle6_x_out,obstacle6_y_out,rgb_out_obs6}),
    .input_7({obstacle7_x_out,obstacle7_y_out,rgb_out_obs7}),
    .input_8(0),
    .input_9(0),
    .input_10(0),
    .input_11(0),
    .input_12(0),
    .input_13(0),
    .input_14(0),
    .input_15(0),
    .select(selected_obstacle),
    
    //outputs
    .obstacle_mux_out(mux_out)
);


delay #(.WIDTH(28), .CLK_DEL(1))  control_signals_delay(
    //inputs
    .clk(clk),
    .rst(rst),
    .din({vcount_in, vsync_in, vblnk_in, hcount_in,  hsync_in, hblnk_in}),
    
    //outputs
    .dout(delayed_signals_out)
);


assign obstacles_counted = obstacles_counted_out;
assign delayed_signals = delayed_signals_out;
assign obstacle_data = mux_out;

endmodule