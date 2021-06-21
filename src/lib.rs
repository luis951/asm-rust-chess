extern crate chess_engine;

use chess_engine::*;
use std::sync::Mutex;
use std::str;

use std::ffi::CStr;

use std::convert::TryFrom;

pub struct ChessBoard {
    board: Board
}

impl ChessBoard {
    fn default() -> ChessBoard {
        ChessBoard{board: Board::default()}
    }

    pub fn set_board(&mut self, new_board: Board) {
        self.board = new_board;
    }

    pub fn get_board(&self) -> Board {
        self.board
    }
}

lazy_static::lazy_static! {
    pub static ref BOARD: Mutex<ChessBoard> = Mutex::new(ChessBoard::default());
}

#[no_mangle]
pub extern "C" fn computerMove(address: &mut [[u8;8];8], steps: u8) -> u8 {
    let mut cur_board = BOARD.lock().unwrap().get_board();

    let (m, _, _) = cur_board.get_best_next_move(steps as i32);

    match cur_board.play_move(m) {
        GameResult::Continuing(next_board) => {
            cur_board = next_board;
            BOARD.lock().unwrap().set_board(cur_board);
        }

        GameResult::Victory(color) => {
            if color == WHITE {
                return 3;
            }
            return 4;
        }

        GameResult::IllegalMove(_) => {
            return 1;
        }

        GameResult::Stalemate => {
            return 5;
        }
    }

    let board = board_to_matrix(cur_board);
    for i in 0..8{
        for j in 0..8{
            address[i][j] = board[i][j];
        }
    }

    return 0;
}

#[no_mangle]
pub extern "C" fn userMove(address: &mut [[u8;8];8], move_str: *const i8) -> u8 {
    let fixed_move_str: String;
    unsafe {
        fixed_move_str = CStr::from_ptr(move_str).to_str().unwrap().to_owned();
    }

    let chess_move = match Move::try_from(fixed_move_str) {
        Ok(var) => var,
        Err(_) => return 2 
    };

    let mut cur_board = BOARD.lock().unwrap().get_board();
    
    match cur_board.play_move(chess_move) {
        GameResult::Continuing(next_board) => {
            cur_board = next_board;
            BOARD.lock().unwrap().set_board(cur_board);
        }

        GameResult::Victory(color) => {
            if color == WHITE {
                return 3;
            }
            return 4;
        }

        GameResult::IllegalMove(_) => {
            return 1;
        }

        GameResult::Stalemate => {
            return 5;
        }
    }
        
    let board = board_to_matrix(cur_board);
    for i in 0..8{
        for j in 0..8{
            address[i][j] = board[i][j];
        }
    }

    return 0;
}


pub fn board_to_matrix(board: Board) -> [[u8;8];8] {
    let mut matrix_board: [[u8;8];8] = [[255; 8];8]; 
    for i in 0..8 {
        for j in 0..8 {
            let piece = match board.get_piece(Position::new(i, j)) {
                Some(ref piece) => format!("{}", piece),
                None => " ".to_string(),
            };

            let num: u8 = match &piece as &str {
                "♚" => 1,
                "♛" => 2,
                "♜" => 3,
                "♝" => 4,
                "♞" => 5,
                "♟︎" => 6,
                "♔" => 1 + 8,
                "♕" => 2 + 8,
                "♖" => 3 + 8,
                "♗" => 4 + 8,
                "♘" => 5 + 8,
                "♙" => 6 + 8,
                _ => 0
            };
            matrix_board[i as usize][j as usize] = num;
        }
    }

    return matrix_board;
}