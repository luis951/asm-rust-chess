use chess;
use std::sync::Mutex;
use std::str::FromStr;
use std::str;

lazy_static::lazy_static! {
    pub static ref GAME: Mutex<chess::Game> = Mutex::new(chess::Game::new());
}

#[no_mangle]
pub extern "C" fn update_asm_board(address: &mut [[u8;8];8], move_str: &[u8;4]) -> u8 {
    let fixed_move_str = str::from_utf8(move_str).unwrap();
    let chess_move = match chess::ChessMove::from_str(&fixed_move_str) {
        Ok(var) => var,
        Err(_) => return 2 
    };
    if !GAME.lock().unwrap().make_move(chess_move){
        return 1;
    }
        
    let board = board_to_matrix(&GAME.lock().unwrap().current_position());
    for i in 0..8{
        for j in 0..8{
            address[7-i][j] = board[i][j];
        }
    }
    return 0;
}


pub fn board_to_matrix(board: &chess::Board) -> [[u8;8];8] {
    let mut matrix_board: [[u8;8];8] = [[255; 8];8];
    let board_to_string = &format!("{}", board);
    let splitted_string: Vec<&str> = board_to_string.split(" ").collect();
    let formated_string: Vec<&str> = splitted_string[0].split("/").collect();
    let mut k = 0;
    for line in formated_string {
        let mut new_line: [u8;8] = [0; 8];
        let mut prev_ch = 'i';
        for (i, ch) in line.chars().enumerate(){
            if (ch>='a' && ch<='z') || (ch>='A' && ch<='Z'){
                if prev_ch>='1' && prev_ch<='7'{
                    new_line[i + prev_ch as usize - 48 - 1] = char_to_int(ch);
                } else {
                    new_line[i] = char_to_int(ch);
                }
            }
            prev_ch = ch;
        }
        matrix_board[k] = new_line;
        k+=1;
    }
    return matrix_board;
}

fn char_to_int(piece: char) -> u8{
    match piece{
        'r' => return 11,
        'n' => return 13,
        'b' => return 12,
        'q' => return 10,
        'k' => return 9,
        'p' => return 14,
        'R' => return 3,
        'N' => return 5,
        'B' => return 4,
        'Q' => return 2,
        'K' => return 1,
        'P' => return 6,
        'e' => return 0,
        _ => return 15
    }
}