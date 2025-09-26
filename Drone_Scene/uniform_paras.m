function out = uniform_paras(message1, message2)
% 多接收站信号参数统一函数
% 功能：合并来自两个接收站的同一个信号的时间-频率参数范围，生成覆盖两者的统一参数。
% 本函数实现了对同一个信号跳变段在不同接收站处检测到的参数的融合。
% 融合策略是取时间范围和频率范围的“并集”。
%
% 输入参数：
%   message1 : 接收站1的信号参数行向量。其列结构通常为 [频率1, 频率2, 时间1, 时间2, 发射台站ID]。
%              来自 ori_message1 的一行，列可能为 [起始频率(Hz), 结束频率(Hz), 起始采样点, 结束采样点, ID]。
%              来自 rec_message1 的一行，列可能为 [起始频率Bin, 结束频率Bin, 起始帧索引, 结束帧索引, ID]。
%   message2 : 接收站2的信号参数行向量。其列结构与 message1 相同，且理论上代表同一个信号跳变段。
%
% 输出参数：
%   out      : 统一后的参数行向量。其列结构与输入相同，但前4列是融合后的范围。
%              如果输入参数的发射台站ID不匹配，则返回 NaN 填充的向量并给出警告。

if message1(5) ~= message2(5)
    % 如果发射台站ID不匹配，表明输入的 message1 和 message2 不对应同一个信号跳变段。
    warning('Mismatch in transmitter IDs during uniform_paras fusion: message1 is from Tx %d, message2 is from Tx %d. Returning NaN.', message1(5), message2(5));
    out = NaN(1, length(message1)); % 返回 NaN 向量，长度与输入向量相同 (假设 message1 和 message2 长度相同)
else
    % --- 原始融合逻辑：如果发射台站ID匹配，执行正常的参数合并 ---
    % 如果两个输入向量确认来自同一个发射台站，则执行参数的融合。

    message_mul = zeros(1, length(message1));       % 或者 length(message2)，因为它们长度应该相同
    message_mul(1) = min(message1(1), message2(1));
    message_mul(2) = max(message1(2), message2(2));
    message_mul(3) = min(message1(3), message2(3));
    message_mul(4) = max(message1(4), message2(4));

    % 融合第5列信息（发射台站编号）
    message_mul(5) = message1(5);
    out = message_mul;
end
end