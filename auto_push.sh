#!/bin/bash

#while true; do date; sleep 300; done
# Thay đổi thư mục làm việc sang thư mục repository của bạn
# Ví dụ: cd /path/to/your/repository
# Nếu tập lệnh này nằm trong thư mục gốc của repository, bạn có thể bỏ qua dòng này.

# Kiểm tra xem có trong một repository Git không
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Lỗi: Đây không phải là một repository Git. Hãy di chuyển đến thư mục repository của bạn."
    exit 1
fi

echo "Bắt đầu tự động đẩy lên GitHub sau mỗi 60 phút..."
echo "Nhấn Ctrl+C để dừng."

while true; do
    echo "-----------------------------------------------------"
    echo "Thời gian hiện tại: $(date)"

    # Kiểm tra các thay đổi
    if output=$(git status --porcelain) && [ -n "$output" ]; then
        echo "Phát hiện thay đổi. Đang tiến hành thêm, commit và đẩy..."

        # Thêm tất cả các tệp đã thay đổi
        git add .
        if [ $? -ne 0 ]; then
            echo "Lỗi: Không thể thêm tệp. Vui lòng kiểm tra."
            # Có thể bạn muốn thêm thông báo hoặc xử lý lỗi ở đây
            sleep 3600 # Chờ 60 phút trước khi thử lại
            continue
        fi

        # Commit với một thông điệp tự động bao gồm ngày giờ
        commit_message="Automated commit - $(date +'%Y-%m-%d %H:%M:%S')"
        git commit -m "$commit_message"
        if [ $? -ne 0 ]; then
            echo "Lỗi: Không thể commit. Có thể không có gì để commit hoặc có lỗi khác."
            # Có thể bạn muốn thêm thông báo hoặc xử lý lỗi ở đây
            sleep 3600 # Chờ 60 phút trước khi thử lại
            continue
        fi

        # Đẩy lên remote repository (mặc định là 'origin' và nhánh hiện tại)
        echo "Đang đẩy lên remote..."
        git push
        if [ $? -ne 0 ]; then
            echo "Lỗi: Không thể đẩy lên remote. Vui lòng kiểm tra kết nối mạng và quyền."
            # Có thể bạn muốn thêm thông báo hoặc xử lý lỗi ở đây
        else
            echo "Đẩy thành công!"
        fi
    else
        echo "Không có thay đổi nào để đẩy."
    fi

    echo "Sẽ kiểm tra lại sau 60 phút."
    sleep 3600 # Chờ 60 phút (3600 giây)
done