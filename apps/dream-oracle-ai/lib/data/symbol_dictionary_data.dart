import '../models/symbol_meaning.dart';

/// Từ điển biểu tượng giấc mơ offline — dùng để:
/// 1) Hiển thị màn "Từ điển giấc mơ" cho người dùng tra cứu.
/// 2) Làm nguồn cho [OfflineInterpreter] khi không có Ollama.
///
/// Đây chỉ là diễn giải mang tính giải trí, không phải khoa học.
class SymbolDictionaryData {
  SymbolDictionaryData._();

  static const List<SymbolMeaning> all = [
    SymbolMeaning(
        keyword: 'rắn',
        category: 'Động vật',
        meaning:
            'Biểu tượng của sự thay đổi, cám dỗ hoặc một mối nguy tiềm ẩn mà bạn đang né tránh.'),
    SymbolMeaning(
        keyword: 'nước',
        category: 'Thiên nhiên',
        meaning:
            'Đại diện cho cảm xúc. Nước trong là tâm trí bình yên, nước đục/lũ là cảm xúc hỗn loạn.'),
    SymbolMeaning(
        keyword: 'bay',
        category: 'Hành động',
        meaning:
            'Khao khát tự do, muốn thoát khỏi áp lực hiện tại hoặc cảm giác tự tin, làm chủ tình huống.'),
    SymbolMeaning(
        keyword: 'rơi',
        category: 'Hành động',
        meaning:
            'Cảm giác mất kiểm soát, lo lắng về một quyết định hoặc sợ thất bại trong đời thực.'),
    SymbolMeaning(
        keyword: 'răng',
        category: 'Cơ thể',
        meaning:
            'Rụng răng thường liên quan đến lo âu về ngoại hình, tuổi tác, hoặc sợ mất mát/nói sai điều gì đó.'),
    SymbolMeaning(
        keyword: 'xe',
        category: 'Phương tiện',
        meaning:
            'Tượng trưng cho hướng đi cuộc đời. Xe mất phanh/hỏng ám chỉ cảm giác mất kiểm soát cuộc sống.'),
    SymbolMeaning(
        keyword: 'nhà',
        category: 'Nơi chốn',
        meaning:
            'Đại diện cho bản thân/tâm trí bạn. Nhà đổ nát gợi ý sự bất an nội tâm; nhà mới gợi ý thay đổi bản thân.'),
    SymbolMeaning(
        keyword: 'chết',
        category: 'Sự kiện lớn',
        meaning:
            'Hiếm khi mang nghĩa đen — thường tượng trưng cho một giai đoạn/thói quen cũ đang kết thúc để mở ra khởi đầu mới.'),
    SymbolMeaning(
        keyword: 'lửa',
        category: 'Thiên nhiên',
        meaning:
            'Đam mê, giận dữ hoặc năng lượng biến đổi mạnh mẽ đang bùng lên trong bạn.'),
    SymbolMeaning(
        keyword: 'tiền',
        category: 'Vật chất',
        meaning:
            'Liên quan đến giá trị bản thân, sự tự tin hoặc lo lắng về tài chính/công việc.'),
    SymbolMeaning(
        keyword: 'nhện',
        category: 'Động vật',
        meaning:
            'Cảm giác bị mắc kẹt trong một tình huống phức tạp, hoặc lo lắng về ai đó đang "giăng bẫy" bạn.'),
    SymbolMeaning(
        keyword: 'chó',
        category: 'Động vật',
        meaning:
            'Lòng trung thành, tình bạn. Chó dữ có thể ám chỉ mâu thuẫn với người thân/bạn bè.'),
    SymbolMeaning(
        keyword: 'mèo',
        category: 'Động vật',
        meaning:
            'Sự độc lập, trực giác. Mèo đen trong một số quan niệm gắn với điềm báo cần thận trọng.'),
    SymbolMeaning(
        keyword: 'biển',
        category: 'Thiên nhiên',
        meaning:
            'Chiều sâu cảm xúc và tiềm thức. Biển động cho thấy nội tâm đang xáo trộn.'),
    SymbolMeaning(
        keyword: 'núi',
        category: 'Thiên nhiên',
        meaning: 'Thử thách lớn phía trước, hoặc mục tiêu bạn đang cố chinh phục.'),
    SymbolMeaning(
        keyword: 'thi',
        category: 'Học tập',
        meaning:
            'Nỗi lo bị đánh giá, áp lực phải chứng minh năng lực bản thân trong công việc/học tập.'),
    SymbolMeaning(
        keyword: 'trễ',
        category: 'Sự kiện lớn',
        meaning:
            'Sợ bỏ lỡ cơ hội, cảm giác chưa chuẩn bị kịp cho một việc quan trọng sắp tới.'),
    SymbolMeaning(
        keyword: 'đuổi',
        category: 'Hành động',
        meaning:
            'Đang né tránh một vấn đề, cảm xúc hoặc trách nhiệm nào đó trong đời thực.'),
    SymbolMeaning(
        keyword: 'khỏa thân',
        category: 'Cơ thể',
        meaning:
            'Cảm giác dễ bị tổn thương, sợ bị người khác nhìn thấu điểm yếu của mình.'),
    SymbolMeaning(
        keyword: 'em bé',
        category: 'Con người',
        meaning:
            'Khởi đầu mới, một dự án/mối quan hệ/ý tưởng còn non trẻ đang cần được chăm sóc.'),
    SymbolMeaning(
        keyword: 'đám cưới',
        category: 'Sự kiện lớn',
        meaning: 'Sự cam kết, hợp nhất hai khía cạnh trong cuộc sống hoặc tính cách của bạn.'),
    SymbolMeaning(
        keyword: 'bay lượn',
        category: 'Hành động',
        meaning: 'Cảm giác tự do và vượt lên trên những giới hạn hiện tại.'),
    SymbolMeaning(
        keyword: 'máu',
        category: 'Cơ thể',
        meaning: 'Năng lượng sống, đam mê mãnh liệt hoặc một tổn thương cảm xúc chưa lành.'),
    SymbolMeaning(
        keyword: 'chìm',
        category: 'Hành động',
        meaning: 'Bị cảm xúc tiêu cực hoặc khối lượng công việc nhấn chìm, cần tìm cách "nổi lên".'),
    SymbolMeaning(
        keyword: 'cửa',
        category: 'Nơi chốn',
        meaning: 'Cơ hội mới hoặc một quyết định mà bạn đang đứng trước ngưỡng lựa chọn.'),
    SymbolMeaning(
        keyword: 'gương',
        category: 'Vật thể',
        meaning: 'Tự soi xét bản thân, câu hỏi về danh tính hoặc cách người khác nhìn nhận bạn.'),
    SymbolMeaning(
        keyword: 'trường học',
        category: 'Nơi chốn',
        meaning: 'Cảm giác đang được "kiểm tra" kỹ năng, hoặc hoài niệm về giai đoạn trưởng thành.'),
    SymbolMeaning(
        keyword: 'điện thoại',
        category: 'Vật thể',
        meaning: 'Mong muốn kết nối, hoặc lo lắng về một thông tin/tin nhắn chưa được giải quyết.'),
    SymbolMeaning(
        keyword: 'bão',
        category: 'Thiên nhiên',
        meaning: 'Biến động lớn sắp xảy ra hoặc cảm xúc dữ dội đang tích tụ.'),
    SymbolMeaning(
        keyword: 'chim',
        category: 'Động vật',
        meaning: 'Thông điệp, tự do tinh thần hoặc một tin tức sắp đến.'),
    SymbolMeaning(
        keyword: 'cá',
        category: 'Động vật',
        meaning: 'Sự sung túc, may mắn hoặc những suy nghĩ tiềm thức đang "bơi" trong đầu bạn.'),
    SymbolMeaning(
        keyword: 'đường',
        category: 'Nơi chốn',
        meaning: 'Hành trình cuộc đời. Đường quanh co gợi ý bạn đang tìm hướng đi rõ ràng hơn.'),
    SymbolMeaning(
        keyword: 'khóa',
        category: 'Vật thể',
        meaning: 'Bí mật, giới hạn hoặc điều gì đó bạn đang cố "mở khóa" trong cuộc sống.'),
    SymbolMeaning(
        keyword: 'tóc',
        category: 'Cơ thể',
        meaning: 'Sức mạnh cá nhân, hình ảnh bản thân. Rụng tóc gợi ý lo lắng về sức hút/quyền lực.'),
    SymbolMeaning(
        keyword: 'chạy',
        category: 'Hành động',
        meaning: 'Nỗ lực đạt mục tiêu hoặc đang cố thoát khỏi áp lực nào đó.'),
    SymbolMeaning(
        keyword: 'sách',
        category: 'Vật thể',
        meaning: 'Khao khát tri thức, hoặc một "chương" mới trong cuộc đời đang được mở ra.'),
    SymbolMeaning(
        keyword: 'thang',
        category: 'Vật thể',
        meaning: 'Tham vọng, mong muốn thăng tiến trong sự nghiệp hoặc phát triển bản thân.'),
    SymbolMeaning(
        keyword: 'quái vật',
        category: 'Sinh vật',
        meaning: 'Nỗi sợ hoặc vấn đề nội tâm bạn chưa dám đối mặt trực diện.'),
    SymbolMeaning(
        keyword: 'bóng tối',
        category: 'Thiên nhiên',
        meaning: 'Điều chưa biết, sự mơ hồ về tương lai hoặc phần bản thân bạn chưa khám phá.'),
    SymbolMeaning(
        keyword: 'ánh sáng',
        category: 'Thiên nhiên',
        meaning: 'Sự tỉnh ngộ, hy vọng hoặc một giải pháp sắp xuất hiện.'),
  ];

  /// Tìm các biểu tượng khớp với [text] (không phân biệt hoa/thường).
  static List<SymbolMeaning> match(String text) {
    final lower = text.toLowerCase();
    return all.where((s) => lower.contains(s.keyword.toLowerCase())).toList();
  }

  /// Lọc theo từ khóa tìm kiếm cho màn Từ điển.
  static List<SymbolMeaning> search(String query) {
    if (query.trim().isEmpty) return all;
    final lower = query.toLowerCase();
    return all
        .where((s) =>
            s.keyword.toLowerCase().contains(lower) ||
            s.category.toLowerCase().contains(lower) ||
            s.meaning.toLowerCase().contains(lower))
        .toList();
  }
}
