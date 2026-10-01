# PRD: Mini-Project #3 — OCR Expense Tracker & Receipt Parser

## 1. Introduction / Overview

Mini-Project #3 là ứng dụng Flutter/Dart hỗ trợ sinh viên và thủ quỹ câu lạc bộ ghi nhận chi tiêu từ hóa đơn giấy. Android là nền tảng chính để phát triển, kiểm thử và demo; project Flutter vẫn duy trì khả năng hỗ trợ iOS. Thay vì phải nhập từng khoản vào bảng tính, người dùng chụp ảnh biên lai, để thiết bị nhận dạng văn bản bằng Google ML Kit và trích xuất các thông tin quan trọng: cửa hàng, ngày giao dịch và tổng tiền. Người dùng luôn có màn hình kiểm tra, chỉnh sửa dữ liệu trước khi lưu.

Dữ liệu giao dịch cùng ảnh biên lai đã crop và nén được lưu cục bộ trên thiết bị. Ứng dụng cũng cung cấp lịch sử có tìm kiếm/lọc và hai biểu đồ tự vẽ bằng `CustomPainter`: biểu đồ donut theo danh mục và biểu đồ cột theo tuần.

## 2. Goals

- Cho phép tạo một giao dịch chi tiêu từ ảnh hóa đơn trong một luồng thao tác rõ ràng: chụp → nhận dạng → kiểm tra → lưu.
- Thực hiện nhận dạng chữ trên thiết bị, không gửi ảnh hoặc văn bản biên lai lên dịch vụ đám mây.
- Trích xuất được tổng tiền, ngày và tên cửa hàng từ các định dạng biên lai Việt Nam phổ biến; ví dụ `150,000 VND`, `150.000 đ`, `12/09/2026`, `12-09-2026`, `2026-09-12`.
- Lưu giao dịch bền vững bằng SQLite qua `sqflite`, kể cả sau khi đóng và mở lại ứng dụng.
- Gợi ý một trong năm danh mục: Food, Study, Travel, Gear, Entertainment bằng bộ keyword do nhóm xây dựng và quản lý tập trung; người dùng có thể đổi trước khi lưu.
- Hiển thị được tình hình chi tiêu theo danh mục và theo tuần bằng canvas tự vẽ, không dùng thư viện biểu đồ bên thứ ba.
- Cung cấp lịch sử giao dịch có tìm kiếm và lọc để người dùng nhanh chóng tra cứu khoản đã lưu.

## 3. User Stories

### US-001: Chụp và căn chỉnh biên lai
**Description:** Là sinh viên hoặc thủ quỹ CLB, tôi muốn chụp biên lai với khung căn chỉnh để ảnh đầu vào dễ đọc và giảm lỗi nhận dạng.

**Acceptance Criteria:**
- [ ] Màn hình quét hiển thị camera preview khi quyền camera đã được cấp.
- [ ] Có nút bật/tắt flash; trạng thái nút phản ánh trạng thái flash hiện tại.
- [ ] Chạm vào vị trí trong preview yêu cầu camera lấy nét tại vị trí đó trên thiết bị hỗ trợ tính năng này.
- [ ] Preview có crop overlay hiển thị vùng biên lai cần đặt vào giữa khung; luồng này được kiểm thử và demo chính trên Android.
- [ ] Ảnh được chụp hoặc crop chỉ từ thao tác xác nhận rõ ràng của người dùng.
- [ ] Xử lý được trường hợp từ chối quyền camera bằng thông báo và đường dẫn/thao tác thử lại phù hợp.
- [ ] Flutter analyze và test liên quan chạy thành công.
- [ ] Verify in browser using dev-browser skill (khi chạy Flutter Web) hoặc kiểm chứng trên Android/iOS emulator/device.

### US-002: Nhận dạng và trích xuất thông tin biên lai
**Description:** Là người dùng, tôi muốn ứng dụng đọc ảnh biên lai và điền sẵn thông tin giao dịch để không phải nhập lại bằng tay.

**Acceptance Criteria:**
- [ ] Ảnh đầu vào được gửi tới `google_mlkit_text_recognition` chạy on-device; không có API upload ảnh/văn bản tới cloud.
- [ ] Màn hình trạng thái cho biết việc nhận dạng đang xử lý và không cho lưu bản ghi chưa hoàn tất.
- [ ] Parser nhận diện tổng tiền cho ít nhất các mẫu `150,000 VND`, `150.000 đ` và `150000` khi có ngữ cảnh nhãn Total/Tổng/Cộng.
- [ ] Parser nhận diện các ngày dạng `DD/MM/YYYY`, `DD-MM-YYYY` và `YYYY-MM-DD`; hỗ trợ năm hai chữ số nếu quy tắc chuyển đổi năm được ghi rõ trong mã/tài liệu.
- [ ] Ngày trích xuất được chuẩn hóa thành một giá trị ngày hợp lệ duy nhất trước khi hiển thị review và trước khi lưu database.
- [ ] Parser chọn tên cửa hàng từ các dòng đầu văn bản khi không phải dòng ngày, tổng tiền hoặc địa chỉ rõ ràng.
- [ ] Nếu không thể suy ra một trường, trường đó để trống và đánh dấu để người dùng nhập thủ công; không tự tạo giá trị giả.
- [ ] Flutter analyze và unit test cho các mẫu regex chạy thành công.

### US-003: Kiểm tra, chỉnh sửa và phân loại giao dịch
**Description:** Là người dùng, tôi muốn xem và sửa kết quả OCR trước khi lưu để dữ liệu chi tiêu chính xác.

**Acceptance Criteria:**
- [ ] Màn hình review hiển thị thumbnail biên lai, văn bản OCR (hoặc phần xem lại phù hợp), merchant, ngày, tổng tiền và danh mục gợi ý.
- [ ] Merchant, ngày và tổng tiền có thể chỉnh sửa trước khi lưu.
- [ ] Tổng tiền chỉ chấp nhận số dương; ngày phải là ngày hợp lệ; các lỗi hiển thị cạnh trường tương ứng.
- [ ] Danh mục gợi ý được xác định từ từ khóa merchant/văn bản và chỉ thuộc Food, Study, Travel, Gear hoặc Entertainment.
- [ ] Bộ keyword cho năm danh mục được định nghĩa tập trung trong code/config, có cấu trúc dễ mở rộng và có unit test cho ít nhất một keyword của mỗi danh mục.
- [ ] Người dùng có thể thay đổi danh mục gợi ý trước khi lưu.
- [ ] Nút lưu chỉ hoạt động khi merchant, ngày, tổng tiền và danh mục hợp lệ.
- [ ] Flutter analyze và test liên quan chạy thành công.
- [ ] Verify in browser using dev-browser skill (khi chạy Flutter Web) hoặc kiểm chứng trên Android/iOS emulator/device.

### US-004: Lưu và quản lý vòng đời giao dịch cục bộ
**Description:** Là người dùng, tôi muốn các giao dịch và thumbnail biên lai của mình vẫn còn sau khi mở lại ứng dụng để theo dõi chi tiêu lâu dài.

**Acceptance Criteria:**
- [ ] SQLite được truy cập qua `sqflite` và có migration/tạo bảng có thể chạy lại an toàn.
- [ ] Mỗi giao dịch lưu tối thiểu: ID, merchant, transaction date, total amount, currency/display amount, category, đường dẫn thumbnail, thời điểm tạo và thời điểm cập nhật.
- [ ] Ảnh biên lai được crop theo vùng người dùng xác nhận, nén với chất lượng đủ tốt để đối chiếu kết quả OCR, rồi lưu vào application documents/support directory; database chỉ lưu đường dẫn cục bộ, không lưu blob ảnh.
- [ ] Bản ảnh đã lưu là JPEG với quality 85%, cạnh dài tối đa 2000 px và mục tiêu kích thước tệp không vượt quá 1–2 MB; thao tác nén không làm ứng dụng bị lỗi khi nguồn ảnh lớn.
- [ ] Sau khi restart ứng dụng, giao dịch và thumbnail còn truy cập được nếu file vẫn tồn tại.
- [ ] Người dùng có thể mở chi tiết, sửa và xóa một giao dịch; xóa giao dịch cũng dọn thumbnail tương ứng nếu không còn bản ghi nào dùng ảnh đó.
- [ ] Flutter analyze và test repository/database chạy thành công.

### US-005: Tra cứu lịch sử giao dịch
**Description:** Là người dùng, tôi muốn tìm kiếm và lọc lịch sử giao dịch để xem đúng khoản chi mình cần.

**Acceptance Criteria:**
- [ ] Danh sách lịch sử sắp xếp giao dịch mới nhất trước theo ngày giao dịch, với quy tắc phụ theo thời điểm tạo khi trùng ngày.
- [ ] Ô tìm kiếm lọc theo merchant, không phân biệt chữ hoa/thường.
- [ ] Người dùng có thể lọc theo một danh mục hoặc tất cả danh mục.
- [ ] Người dùng có thể lọc theo khoảng ngày có ngày bắt đầu và ngày kết thúc hợp lệ.
- [ ] Khi không có kết quả, hiển thị empty state thay vì danh sách trống không giải thích.
- [ ] Bộ lọc hiện tại được giữ trong lúc chuyển giữa lịch sử, chi tiết và quay lại lịch sử trong cùng phiên ứng dụng.
- [ ] Flutter analyze và test liên quan chạy thành công.
- [ ] Verify in browser using dev-browser skill (khi chạy Flutter Web) hoặc kiểm chứng trên Android/iOS emulator/device.

### US-006: Xem phân tích chi tiêu bằng canvas
**Description:** Là người dùng, tôi muốn xem tỷ trọng danh mục và tổng chi theo tuần để hiểu thói quen chi tiêu của mình.

**Acceptance Criteria:**
- [ ] Dashboard vẽ biểu đồ donut/pie theo tổng chi của từng danh mục trong bộ lọc thời gian hiện tại.
- [ ] Dashboard vẽ biểu đồ cột cho tổng chi theo tuần, với nhãn tuần và trục/giá trị đủ để diễn giải dữ liệu.
- [ ] Cả hai biểu đồ được vẽ trực tiếp bằng Flutter `CustomPainter`; không thêm package biểu đồ.
- [ ] Biểu đồ có animation xuất hiện/cập nhật mượt và không chặn thao tác UI.
- [ ] Khi chưa có dữ liệu, biểu đồ hiển thị trạng thái không có dữ liệu, không lỗi chia cho 0 hoặc vẽ giá trị không hợp lệ.
- [ ] Chú giải donut cho biết tên danh mục, màu và tổng tiền/tỷ lệ tương ứng.
- [ ] Flutter analyze và test logic tính toán dữ liệu biểu đồ chạy thành công.
- [ ] Verify in browser using dev-browser skill (khi chạy Flutter Web) hoặc kiểm chứng trên Android/iOS emulator/device.

### US-007: Chuẩn bị gói nộp mini-project
**Description:** Là sinh viên nộp bài, tôi muốn repository và tài liệu bàn giao rõ ràng để người chấm có thể build, chạy và đánh giá ứng dụng.

**Acceptance Criteria:**
- [ ] `README.md` nêu Flutter/Dart version, các lệnh cài dependency, chạy app, test và build release APK.
- [ ] README chứa liên kết tải `app-release.apk` (GitHub Releases hoặc Drive) và liên kết video demo quét OCR.
- [ ] Repository công khai, không commit secrets, file database runtime hoặc ảnh biên lai thật chứa dữ liệu nhạy cảm.
- [ ] Có báo cáo kỹ thuật PDF dài 2–4 trang theo standard template, mô tả kiến trúc, OCR/parser, persistence, CustomPainter và kết quả.
- [ ] APK release build thành công từ repository theo hướng dẫn README.

## 4. Functional Requirements

- FR-1: Ứng dụng phải chạy trên Flutter 3.x và Dart 3; Android là nền tảng chính để phát triển, kiểm thử và demo, đồng thời project phải duy trì khả năng build/hỗ trợ iOS.
- FR-2: Ứng dụng phải yêu cầu quyền camera trước khi mở viewfinder và xử lý trạng thái quyền bị từ chối.
- FR-3: Viewfinder phải có flash toggle, tap-to-focus (nếu camera/OS hỗ trợ) và crop overlay.
- FR-4: Sau khi người dùng xác nhận ảnh, hệ thống phải chạy Google ML Kit Text Recognition ngay trên thiết bị.
- FR-5: Hệ thống không được truyền ảnh biên lai hay kết quả OCR tới dịch vụ cloud như một phần của luồng xử lý chuẩn.
- FR-6: Heuristic parser phải trích xuất/đề xuất merchant, transaction date và total amount từ văn bản OCR; mỗi trường phải có thể thiếu khi độ tin cậy không đủ.
- FR-6a: Parser ngày phải hỗ trợ `DD/MM/YYYY`, `DD-MM-YYYY` và `YYYY-MM-DD`, sau đó chuẩn hóa ngày hợp lệ về một định dạng lưu trữ thống nhất trước khi ghi database.
- FR-7: Parser phải ưu tiên các dòng mang nhãn tổng tiền (`TOTAL`, `TỔNG`, `CỘNG`, hoặc biến thể đã định nghĩa) hơn các số tiền dòng hàng.
- FR-8: Người dùng phải có thể sửa toàn bộ trường do OCR/parser đề xuất trước khi lưu.
- FR-9: Hệ thống phải gợi ý danh mục dựa trên bộ keyword do nhóm xây dựng, quản lý tập trung trong code/config, đồng thời cho phép chọn thủ công Food, Study, Travel, Gear hoặc Entertainment.
- FR-10: Hệ thống phải crop ảnh biên lai, nén thành JPEG quality 85% với cạnh dài tối đa 2000 px và mục tiêu dung lượng không quá 1–2 MB/ảnh, sau đó lưu tệp trong thư mục ứng dụng và lưu giao dịch trong SQLite qua `sqflite`.
- FR-11: Hệ thống phải cho phép xem, sửa và xóa giao dịch đã lưu.
- FR-12: Lịch sử phải hỗ trợ tìm kiếm merchant, lọc danh mục và lọc khoảng ngày.
- FR-13: Dashboard phải tổng hợp giao dịch để vẽ donut theo danh mục và bar chart theo tuần bằng `CustomPainter`.
- FR-14: Dashboard và lịch sử phải hoạt động đúng với trạng thái không có giao dịch.
- FR-15: Người dùng phải có thể build APK release và truy cập đủ ba deliverable nộp bài: APK/video, repository, PDF report.

## 5. Non-Goals (Out of Scope)

- Không xây dựng tài khoản người dùng, đăng nhập, đồng bộ cloud hoặc chia sẻ dữ liệu giữa nhiều thiết bị.
- Không hỗ trợ sao kê ngân hàng, QR thanh toán, import CSV/PDF, hoặc kết nối ngân hàng.
- Không cam kết OCR chính xác tuyệt đối; màn hình review thủ công là phần bắt buộc để xử lý sai lệch.
- Không xây dựng nhận diện từng mặt hàng, số lượng, thuế, giảm giá hoặc tách một biên lai thành nhiều khoản chi.
- Không có quy đổi ngoại tệ, đa tiền tệ đầy đủ, ngân sách, nhắc nhở hay cảnh báo vượt ngân sách.
- Không dùng thư viện biểu đồ bên thứ ba.
- Không tối ưu cho hệ thống kế toán doanh nghiệp, phân quyền nhiều người dùng, hay workflow phê duyệt chi.

## 6. Design Considerations

- Luồng chính cần ưu tiên thao tác một tay: Dashboard/Historical → Scan → Review → Save.
- Crop overlay nên có độ tương phản đủ cao nhưng không che mất nội dung camera; hiển thị hướng dẫn ngắn như “Đặt biên lai trong khung”.
- Trường được OCR điền sẵn cần có nhãn rõ, định dạng tiền tệ dễ đọc theo VND, và dấu hiệu trực quan nếu thiếu/chưa hợp lệ.
- Nhãn/màu danh mục phải nhất quán giữa form, lịch sử, donut legend và bar chart; không chỉ truyền đạt danh mục bằng màu để bảo đảm khả năng tiếp cận.
- Biểu đồ cần có nhãn/legend thay vì chỉ dựa vào hình vẽ canvas.

## 7. Technical Considerations

- Android là target chính cho CI/test thủ công/demo. iOS vẫn phải được giữ tương thích ở mức project và dependency; mọi khác biệt camera/ML Kit theo nền tảng phải được ghi trong README.
- Dependencies dự kiến: Flutter 3.x, Dart 3, `camera`, `google_mlkit_text_recognition`, `sqflite`, `path_provider` và package xử lý ảnh/crop/nén phù hợp nếu cần.
- Cần đóng `TextRecognizer` và camera controller khi màn hình bị dispose để tránh rò rỉ tài nguyên.
- Chuẩn hóa tổng tiền thành đơn vị số nguyên VND (`int`) trong database để tránh lỗi làm tròn `double`; định dạng lại khi hiển thị.
- Regex/parser nên được tách thành service có fixture văn bản OCR và unit test. Thứ tự heuristic đề xuất: xác định dòng tổng tiền có nhãn → parse/chuẩn hóa số → parse ngày → chọn merchant từ vùng dòng đầu.
- Parser ngày phải nhận các pattern `DD/MM/YYYY`, `DD-MM-YYYY`, `YYYY-MM-DD` và chuẩn hóa thành ISO-8601 date-only (`YYYY-MM-DD`) trước khi lưu SQLite. UI có thể định dạng lại theo locale để hiển thị.
- Bộ keyword danh mục phải nằm trong một file/config/service tập trung thay vì rải điều kiện trong UI; mỗi keyword ánh xạ rõ tới đúng một trong năm danh mục và có test regression.
- Pipeline ảnh phải crop trước, sau đó nén và lưu phiên bản đã xử lý. Cấu hình bắt buộc là JPEG quality 85%, cạnh dài tối đa 2000 px, mục tiêu ≤1–2 MB/ảnh; cần kiểm chứng ảnh kết quả còn đủ rõ để đối chiếu nội dung OCR.
- Với định dạng năm hai chữ số, quy ước khuyến nghị là `00–69` → `2000–2069`, `70–99` → `1970–1999`; quy tắc phải hiển thị trong code/test nếu hỗ trợ.
- Schema cần index ít nhất cho ngày giao dịch và danh mục để truy vấn lịch sử/lọc hiệu quả với dữ liệu cá nhân.
- Tính toán dữ liệu biểu đồ nên tách khỏi `CustomPainter`; painter chỉ nhận model đã tổng hợp và `animation progress`.
- Mục tiêu “sub-100ms” là mục tiêu trải nghiệm tham khảo cho bước gọi/khởi tạo xử lý trên thiết bị phù hợp, không phải cam kết tuyệt đối cho toàn bộ ảnh và mọi thiết bị. Cần đo thời gian trên một thiết bị kiểm thử được ghi trong báo cáo.

## 8. Success Metrics

- Người dùng có thể hoàn tất luồng chụp, review và lưu một biên lai trong tối đa 60 giây ở điều kiện ảnh rõ.
- Với bộ ít nhất 20 biên lai Việt Nam có ảnh rõ, parser đề xuất đúng tổng tiền và ngày cho ít nhất 80% mẫu trước khi người dùng sửa; merchant đúng ở mức có thể nhận biết cho ít nhất 70% mẫu.
- Bộ đánh giá OCR/parser gồm 20–30 biên lai chuẩn, bao gồm trường hợp dễ và khó; cùng một bộ dữ liệu phải được dùng cho mọi lần đo và báo cáo kết quả.
- 100% giao dịch đã lưu vẫn hiển thị sau khi khởi động lại ứng dụng trong kiểm thử thủ công.
- Với ít nhất 100 giao dịch seed/test, tìm kiếm, lọc và mở dashboard phản hồi trong khoảng 1 giây trên thiết bị Android kiểm thử.
- Cả hai biểu đồ được xác nhận không phụ thuộc package chart bên thứ ba qua dependency review.
- APK release build thành công và ba deliverable nộp bài đều có thể truy cập từ README.

