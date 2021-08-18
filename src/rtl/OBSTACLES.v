`timescale 1 ns / 1 ps

// PWJ added module for managing obstacles

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
    input wire play_selected,
    
    output wire [15:0] obstacles_counted,
    output wire [27:0] delayed_signals,
    output wire [35:0] obstacle_data
);

// The order in which the obstacles will be displayed. From 0 (first) to 7 (last). 
// If you want to change it you must change connection order in obstacle_mux_8_to_1 accordingly to order below
// or nothing will display on the screen.
localparam PILLARS_CODE            = 0,
           VERTICAL_LASERS_CODE    = 1,
           HORIZONTAL_LASERS_CODE  = 2,
           SQUARE_FOLLOW_CODE      = 3,
           MOUSE_FOLLOWER_CODE     = 4,
           FALLING_SPIKES_CODE     = 5,
           SPLITTING_OBSTACLE_CODE = 6;

wire [35:0] mux_out;
wire [27:0] delayed_signals_out;

wire [15:0] obstacles_counted_out;

wire [11:0] rgb_out_obs0, rgb_out_obs1, rgb_out_obs2, rgb_out_obs3, rgb_out_obs4, rgb_out_obs5, rgb_out_obs6;
wire [11:0] obstacle0_x_out,obstacle0_y_out, obstacle1_x_out, obstacle1_y_out, obstacle2_x_out, obstacle2_y_out, obstacle3_x_out, obstacle3_y_out;
wire [11:0] obstacle4_x_out,obstacle4_y_out, obstacle5_x_out, obstacle5_y_out, obstacle6_x_out, obstacle6_y_out;
wire [2:0] selected_obstacle;

wire done_obs0, done_obs1, done_obs2, done_obs3, done_obs4, done_obs5, done_obs6, done_control, done_counter;

pillars_obstacle #(.SELECT_CODE(PILLARS_CODE)) pillars_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
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

lasers_obstacle #(.SELECT_CODE(VERTICAL_LASERS_CODE)) vertical_lasers_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
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

horizontal_lasers_obstacle #(.SELECT_CODE(HORIZONTAL_LASERS_CODE)) horizontal_lasers_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
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

square_follow_obstacle #(.SELECT_CODE(SQUARE_FOLLOW_CODE)) square_follow_obstacle (
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
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

mouse_follower_obstacle #(.SELECT_CODE(MOUSE_FOLLOWER_CODE)) mouse_follower_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
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

falling_spikes_obstacle #(.SELECT_CODE(FALLING_SPIKES_CODE)) falling_spikes_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
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

splitting_obstacle #(.SELECT_CODE(SPLITTING_OBSTACLE_CODE)) splitting_obstacle(
    //inputs
    .vcount_in(vcount_in),
    .hcount_in(hcount_in),
    .clk(clk),
    .rst(rst),
    .rgb_in(rgb_in),
    .play_selected(play_selected),
    .selected(selected_obstacle),
    .done_in(done_counter),
    .mouse_xpos(xpos),
    .mouse_ypos(ypos),
    
    //outputs  
    .obstacle_x(obstacle6_x_out),
    .obstacle_y(obstacle6_y_out),
    .rgb_out(rgb_out_obs6),
    .done(done_obs6) 
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
    .done(done_obs0 || done_obs1 || done_obs2 || done_obs3 || done_obs4 || done_obs5 || done_obs6),
    .play_selected(play_selected),
    
    //outputs
    .obstacle_code(selected_obstacle),
    .done_out(done_control)
);

obstacle_mux_7_to_1 obstacle_mux (
    //inputs
    .input_0({obstacle0_x_out,obstacle0_y_out,rgb_out_obs0}),
    .input_1({obstacle1_x_out,obstacle1_y_out,rgb_out_obs1}),
    .input_2({obstacle2_x_out,obstacle2_y_out,rgb_out_obs2}),
    .input_3({obstacle3_x_out,obstacle3_y_out,rgb_out_obs3}),
    .input_4({obstacle4_x_out,obstacle4_y_out,rgb_out_obs4}),
    .input_5({obstacle5_x_out,obstacle5_y_out,rgb_out_obs5}),
    .input_6({obstacle6_x_out,obstacle6_y_out,rgb_out_obs6}),
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