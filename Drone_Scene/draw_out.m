function draw_out(out,color)

hold on 
for ii = 1:length(out(:,1))
    left_under = [out(ii,1) out(ii,4)];
    right_under = [out(ii,2) out(ii,4)];
    left_on = [out(ii,1) out(ii,3)];
    right_on = [out(ii,2) out(ii,3)];
    
    plot([left_under(1) right_under(1)],[left_under(2) right_under(2)],color,'LineWidth',3);
    plot([left_under(1) left_on(1)],[left_under(2) left_on(2)],color,'LineWidth',3);
    plot([right_on(1) right_under(1)],[right_on(2) right_under(2)],color,'LineWidth',3);
    plot([right_on(1) left_on(1)],[right_on(2) left_on(2)],color,'LineWidth',3);
end

end