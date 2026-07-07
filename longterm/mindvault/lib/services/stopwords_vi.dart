/// Danh sách stopword tiếng Việt (từ nối, hư từ) dùng để loại bỏ khi trích
/// từ khóa tự động cho tính năng gợi ý tag. Không đầy đủ tuyệt đối, chỉ đủ
/// dùng để lọc bớt các từ phổ biến không mang ý nghĩa chủ đề.
class StopwordsVi {
  static const Set<String> words = {
    'và', 'là', 'của', 'có', 'không', 'cho', 'với', 'các', 'một', 'những',
    'này', 'đó', 'đây', 'kia', 'khi', 'thì', 'mà', 'để', 'ở', 'trong',
    'ngoài', 'trên', 'dưới', 'từ', 'đến', 'về', 'theo', 'như', 'nên', 'vì',
    'do', 'bị', 'được', 'sẽ', 'đã', 'đang', 'rất', 'quá', 'cũng', 'còn',
    'nữa', 'chỉ', 'chưa', 'nhưng', 'nếu', 'hay', 'hoặc', 'vậy', 'thế', 'ạ',
    'nhé', 'à', 'ừ', 'ơi', 'nha', 'nhá', 'đi', 'lại', 'ra', 'vào', 'lên',
    'xuống', 'qua', 'sau', 'trước', 'giữa', 'bên', 'cùng', 'mỗi', 'mọi',
    'tất', 'cả', 'tôi', 'tớ', 'mình', 'bạn', 'anh', 'chị', 'em', 'ta',
    'chúng', 'họ', 'nó', 'ai', 'gì', 'sao', 'nào', 'bao', 'nhiêu', 'lần',
    'thôi', 'luôn', 'mới', 'cứ', 'phải', 'cần', 'muốn', 'nói', 'làm',
    'the', 'and', 'is', 'in', 'to', 'of', 'for', 'a', 'an', 'on', 'at',
  };

  static bool isStopword(String word) => words.contains(word.toLowerCase());
}
