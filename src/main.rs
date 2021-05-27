use chess;
use std::str::FromStr;

mod lib;

fn main() {
    let mut board_matrix = lib::board_to_matrix(&lib::GAME.lock().unwrap().current_position());
    print_board(board_matrix);
    let mut move_str = ['h' as u8, '2' as u8,'h' as u8, '4' as u8];
    println!("{}", lib::update_asm_board(&mut board_matrix, &move_str));
    print_board(board_matrix);
    move_str = ['h' as u8, '7' as u8,'h' as u8, '6' as u8];
    println!("{}", lib::update_asm_board(&mut board_matrix, &move_str));
    print_board(board_matrix);
    move_str = ['d' as u8, '2' as u8,'d' as u8, '4' as u8];
    println!("{}", lib::update_asm_board(&mut board_matrix, &move_str));
    print_board(board_matrix);
    move_str = ['d' as u8, '7' as u8,'d' as u8, '6' as u8];
    println!("{}", lib::update_asm_board(&mut board_matrix, &move_str));
    print_board(board_matrix);
    move_str = ['f' as u8, '2' as u8,'f' as u8, '4' as u8];
    println!("{}", lib::update_asm_board(&mut board_matrix, &move_str));
    print_board(board_matrix);
}

fn print_board(board: [[u8 ;8];8]){
    for line in &board{
        println!("{:?}", line);
    }
}