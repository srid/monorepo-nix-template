#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}

#[no_mangle]
pub extern "C" fn double_input(x: i32) -> i32 {
    2 * x
}
