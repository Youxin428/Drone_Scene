function strength = strength_est_water(water1, rec_message)

power = 0;
for i = rec_message(1) : rec_message(2)
    for j = rec_message(3) : rec_message(4)
        power = water1(j, i) + power;
    end
end
strength = power / ((rec_message(2)-rec_message(1)+1) * (rec_message(4)-rec_message(3)+1));

end