%% 滤波器截止频率==Fd/2，选择内部函数成型滤波器
% 功能：根据选定的调制类型、符号序列、符号速率和采样频率，
% 生成经过成型滤波和必要重采样的基带信号。
%
% label：选取生成信号的种类，可选信号种类：BPSK、8PSK、QPSK、16QAM、2FSK、DQPSK4、OQPSK, 2ASK, 64QAM
% msg：信号符号序列（通常是比特或符号映射后的星座点）
% Fd：码元速率 (Symbol Rate)，可能为非整数值。
% Fs：采样频率 (Sampling Frequency)，整数值。
%
% 输出参数：
% base_sig：生成并处理后的基带信号向量。
%
function base_sig = inside_sig_produce_with_filter_up_Fd2(label,msg,Fd,Fs)

% 计算理想的采样点/符号比 (Oversampling Factor)。
L = Fs/Fd;

% 初始化新采样率 (如果在调整 L 后需要重采样) 和一个标志。
% new_Fs = Fs; % <-- 这行不再需要，因为我们会直接计算 P/Q 比率
key = 0; % 标志，指示是否对 L 进行了调整

% 如果理想的采样点/符号比不是整数，则进行调整。
if rem(L,1) ~= 0
    % 将 L 向上取整到最近的整数。这个整数 L 将用于 upfirdn 函数作为上采样因子。
    L = ceil(L);
    % 如果向上取整后的 L 是奇数，则再加 1 使其成为偶数。
    % 这可能是一些滤波器设计或 upfirdn 使用场景的要求。
    if mod(L,2)==1
        L=L+1;
    end
    % new_Fs = L*Fd; % <-- 移除这行！这是导致错误的地方，因为它计算了一个非整数的频率。
    % 我们需要的是重采样比例的整数表示 P 和 Q，而不是这个中间频率 new_Fs。
    key = 1; % 设置标志，表示 L 被调整了，后续需要重采样。
end

% 滤波器参数定义。
beta = 0.35; % 升余弦滚降系数，决定滤波器的频域滚降特性。
span = 8; % 滤波器的截断符号范围。滤波器长度通常是 span * L + 1。
shape = 'normal'; % 滤波器形状，'normal' 表示根升余弦滤波器 (Root Raised Cosine)。

% 设计升余弦成型滤波器系数。
% rcosdesign 函数返回的是时域的滤波器抽头系数 h1。
% L 是每个符号的采样点数 (在进行 upfirdn 上采样后)。
h1 = rcosdesign(beta,span,L,shape); % 成型滤波器系数 h1

% --- 原始代码中的滤波器频域处理和逆变换 ---
% 这部分代码看起来不是标准的滤波器设计或应用流程，它对滤波器系数 h1 进行了 FFT，
% 然后进行幅度归一化，再进行 IFFT 得到最终使用的滤波器系数 h。
% 标准做法通常是直接使用 rcosdesign 返回的 h1 作为滤波器系数。
% 暂保留这部分逻辑，虽然可能不是最优或最标准的方式。
h2 = fft(h1);
h3 = h2./max(abs(h2)); % 注意：这里应该是 abs(h2) 以获取幅度进行归一化
h = ifft(h3);
% 确保滤波器系数是实数或复数，取决于 upfirdn 的输入。对于实数基带信号，h 应该是实数对称的。
% 如果输入 Rsignal 是复数，h 也可以是复数。rcosdesign 返回的是实数滤波器。
% 经过上面的 FFT/IFFT 循环，如果 h1 是实数，h 可能会有微小的虚部。
% 建议：如果 h1 应该直接使用，考虑移除这几行。
% --- 结束原始代码中的滤波器频域处理和逆变换 ---

%% --- 绘制成型滤波器的形状 (注释掉) ---
% figure;   % 创建一个新的图形窗口
% stem(h1); % 使用杆状图绘制离散的冲激响应点
% grid on;
% title('升余弦滤波器冲激响应 (h1 - 来自 rcosdesign)');
% xlabel('样本 (Samples)');
% ylabel('幅度 (Amplitude)');
%%

% --- 根据信号种类进行调制和滤波 ---
switch label
    case 'BPSK'
        M = 2; % BPSK 是二进制相移键控，有两个星座点。
        ini_phase = 0; % 初始相位。
        Rsignal = pskmod(msg,M,ini_phase); % 将消息序列 msg 进行 BPSK 调制。
        % 使用 upfirdn 函数将调制后的符号序列 Rsignal 上采样 L 倍并与滤波器 h 进行卷积。
        % upfirdn(x, h, p, q) 等效于 upsample(x, p) 再 filter(h, 1, ...)，最后 downsample(..., q)。
        % 这里调用 upfirdn(Rsignal, h, L)，等效于 upsample(Rsignal, L) 并 filter(h, 1, ...)。
        % upsample(Rsignal, L) 在每个符号后插入 L-1 个零，将采样率从 Fd 提高到 L*Fd。
        % 然后应用滤波器 h。输出信号 base_sig 的采样率是 L*Fd。
        base_sig = upfirdn(Rsignal,h,L);

    case 'QPSK'
        M = 4; % QPSK 是四进制相移键控，有四个星座点。
        ini_phase = pi/4; % 初始相位。
        Rsignal = pskmod(msg,M,ini_phase); % QPSK 调制。
        scatterplot(Rsignal); % 可选绘制星座图。
        base_sig = upfirdn(Rsignal,h,L); % 上采样 L 倍并滤波。

    case '8PSK'
        M = 8; % 8PSK 是八进制相移键控。
        ini_phase = 0;
        Rsignal = pskmod(msg,M,ini_phase); % 8PSK 调制。
        scatterplot(Rsignal); % 可选绘制星座图。
        base_sig = upfirdn(Rsignal,h,L); % 上采样 L 倍并滤波。

    case '16QAM'
        M = 16; % 16QAM 是十六进制正交幅度调制。
        Rsignal = qammod(msg,M); % 16QAM 调制。
        d = 1/3; % 星座图缩放因子，确保平均功率为 1。
        Rsignal = d.*Rsignal; % 缩放星座图。
        base_sig = upfirdn(Rsignal,h,L); % 上采样 L 倍并滤波。

    case '2FSK'
        % Note: FSK 调制与 PSK/QAM 不同，通常不需要成型滤波器。
        % fskmod 函数直接生成带通 FSK 信号，或者生成基带表示。
        % 检查 fskmod 的用法。如果它生成基带，可能不需要后面的 resample 和滤波器应用。
        % 如果它生成的是符号序列，那么 L 参数在这里可能用于指定每个符号的采样点数。
        % Fs 也是 fskmod 的输入参数。
        % 这里的 Fre_space = Fd; 可能不是正确的频率间隔设置。通常频率间隔与符号速率或带宽相关。
        Fre_space = Fd; % 频率间隔。根据帮助文档，这应该是两个频率之间的间隔，单位 Hz。
        % fskmod(msg,M,freqsep,nsamp,Fs)
        % M 是调制阶数 (这里是 2)
        % freqsep 是载频间隔 (这里使用了 Fd)
        % nsamp 是每个符号的采样点数 (这里使用了 L)
        % Fs 是采样率
        base_sig = fskmod(msg,2,Fre_space,L,Fs); % 直接生成 FSK 信号。这个输出应该已经是采样率为 Fs 的信号。
        % Note: 对于 FSK，upfirdn 和后面的 resample/滤波逻辑可能不适用或需要调整。
        % 假设 fskmod 输出的是在 Fs 采样率下的信号，并且不需要进一步成型滤波或重采样。
        % 如果是这样，这个 case 的逻辑应该直接返回 fskmod 的结果。
        % 为了修复 resample 错误并与原结构兼容，我们保留后面的 resample 块，
        % 但要注意 FSK 信号的处理流程可能与 PSK/QAM 不同。

    case 'DQPSK4'
        M = 4; % 差分 QPSK。
        ini_phase = pi/4;
        Rsignal = dpskmod(msg,M,ini_phase); % DQPSK 调制。
        base_sig = upfirdn(Rsignal,h,L); % 上采样 L 倍并滤波。

    case 'OQPSK'
        M = 4; % 偏移 QPSK。
        % OQPSK 通常需要对 Q 通道符号延迟半个符号周期。
        % 这里的实现似乎是将 I/Q 分离，然后对 Q 通道进行 upsample(..., 2) 和 reshape，再延迟一个采样点（通过在 Q 信号前面加零，I 信号后面加零）。
        % 这是一种非标准的 OQPSK 符号处理方式。标准的 OQPSK 成型滤波是将 I/Q 分别上采样并滤波，Q 通道相对于 I 通道有一个符号周期的移位。
        Rsignal = pskmod(msg,M,pi/4); % 先进行标准 QPSK 调制获取 I/Q 分量。
        I_sig1 = real(Rsignal).'; % 提取实部 (I 通道) 并转置。
        I_sig2 = upsample(I_sig1,2); % I 通道上采样 2 倍（这里不是 L 倍，可能是一个错误或特殊设计）。
        I_sig = reshape(I_sig2,1,[]); % 重塑为行向量。
        Q_sig1 = imag(Rsignal).'; % 提取虚部 (Q 通道) 并转置。
        Q_sig2 = upsample(Q_sig1,2); % Q 通道上采样 2 倍。
        Q_sig = reshape(Q_sig2,1,[]); % 重塑为行向量。
        % 延迟 Q 通道一个采样点。这里的延迟是相对于 2 倍上采样率而言的，不是符号速率的半个符号周期。
        I_sig = [I_sig 0]; % 在 I 通道末尾加零。
        Q_sig = [0 Q_sig]; % 在 Q 通道开头加零。
        % Note: 这个延迟一个采样点的操作是在 2 倍上采样率下进行的，不是标准的 OQPSK 延迟 L/2 个采样点在 L 倍上采样率下。
        % 标准 OQPSK 应在 L 倍上采样后，Q 通道相对 I 通道移位 L/2 个采样点。
        % 这里的长度处理 ([I_sig 0], [0 Q_sig]) 可能导致 I 和 Q 长度不完全一致，需要检查。
        Rsignal = complex(I_sig,Q_sig); % 合并 I/Q 成复数信号。
        % 对非标准的 OQPSK 符号序列进行上采样 L 倍并滤波。
        % Note: 标准 OQPSK 成型滤波是将 I/Q 分别上采样 L 倍并与滤波器的偶数/奇数抽头卷积。
        % 这里的 upfirdn 是对合并后的复数信号进行 L 倍上采样和滤波。
        base_sig = upfirdn(Rsignal,h,L);

    case '2ASK'
        % 2ASK 是二进制幅度键控。
        M = 2;
        ini_phase = 0;
        Rsignal = pskmod(msg,M,ini_phase); % 2PSK 调制，输出是 -1 和 1。
		Rsignal(Rsignal==0) = -1; % 确保输出是 -1 和 1，而不是 0 和 1。
        % Note: 这实际上是 BPSK，而不是 ASK。ASK 通常将比特映射到 0 和 1 或其他非对称幅度。
        % 如果需要生成 0 和 1 的 ASK，应使用 pammod 函数。例如 pammod(msg, 2, 0, 'gray') 映射 0->0, 1->1。
        % 或者手动映射 msg 为 0 和 1，然后乘以幅度电平。
        base_sig = upfirdn(Rsignal,h,L); % 上采样 L 倍并滤波。

	case '64QAM'
        % 64QAM 是六十四进制正交幅度调制。
        M = 64;
        Rsignal = qammod(msg,M); % 64QAM 调制。
        d = 1/7; % 星座图缩放因子。对于 64QAM，标准缩放因子通常是基于星座点到原点的平均距离或最小距离，与 M 相关。1/7 可能是一个近似值。
        Rsignal = d.*Rsignal; % 缩放星座图。
        base_sig = upfirdn(Rsignal,h,L); % 上采样 L 倍并滤波。

	otherwise
        % 如果 label 不是以上列出的任何一种，打印错误信息。
        error('未知的信号种类： %s', label); % 使用 error 而不是简单打印，中断执行并报告错误。
end

% --- 修复 resample 错误：计算重采样比例的整数表示 P 和 Q ---
% 当 L 被调整过时 (key == 1)，当前信号 base_sig 的采样率是 L * Fd，需要重采样到目标采样率 Fs。
% 重采样的比例是 Target_Rate / Original_Rate = Fs / (L * Fd)。
% 使用 rat() 函数计算这个比例的最简整数分数表示 [P_int, Q_int]。
% 然后使用 resample(signal, P_int, Q_int) 进行重采样。
if key == 1 % 这个块只有在 Fs/Fd 最初不是整数时执行。
    % 计算从当前采样率 L*Fd 到目标采样率 Fs 的比例。
    resampling_ratio = Fs / (L * Fd);
    % 使用 rat 函数找到这个比例的最简整数分数表示 P_int / Q_int。
    [P_int, Q_int] = rat(resampling_ratio);

    % 使用计算出的整数比例 P_int 和 Q_int 对信号进行重采样。
    % 这将 base_sig 从采样率 L*Fd 重采样到 Fs。
    base_sig = resample(base_sig, P_int, Q_int);
    % Note: 重采样可能会导致信号长度有微小变化，最终长度由 get_bpsk 函数末尾的截取保证。
end
% --- 修复 resample 错误结束 ---

% --- 移除滤波器引起的时延 ---
filter_len = length(h); % 获取滤波器的长度。
% 移除滤波器引入的时延。对于 rcosdesign，标准时延是 span * L / 2 采样点（在 upfirdn 的输出率下）。
% 这里的移除方式是简单地移除信号开头和结尾的一部分点，数量基于滤波器长度。
% ceil(filter_len/2) 是从信号开头移除的点数。
% end-floor(filter_len/2) 是保留的信号的结束索引。
% Note: 如果进行了重采样 (key == 1)，这里的时延移除可能需要根据重采样比例进行调整，
% 以准确移除在最终 Fs 采样率下的滤波器时延。当前实现是移除固定数量的点。
base_sig = base_sig(ceil(filter_len/2):end-floor(filter_len/2));

% 确保输出信号是行向量。
base_sig = reshape(base_sig,1,[]);

% 函数执行完毕，返回处理后的基带信号向量。
end