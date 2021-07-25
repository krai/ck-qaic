        template <typename A, typename B>
void pack(
                const std::vector<A> &part1,
                const std::vector<B> &part2,
                std::vector<std::pair<A,B>> &packed)
{
        //assert(part1.size() == part2.size());
        for(size_t i = 0; i < part1.size(); i++)
        {
                packed.push_back(std::make_pair(part1[i], part2[i]));
        }
}

        template <typename A, typename B>
void unpack(
                const std::vector<std::pair<A, B>> &packed,
                std::vector<A> &part1,
                std::vector<B> &part2
          )
{
        for(size_t i = 0; i < part1.size(); i++)
        {
                part1[i] = packed[i].first;
                part2[i] = packed[i].second;
        }
}
#define AREA(y1,x1,y2,x2) ((y2-y1) * (x2-x1))
float computeIOU(const float *box1,const float *box2)
{
   float box1_y1 = box1[1], box1_x1 = box1[2], box1_y2 = box1[3], box1_x2 = box1[4];
   float box2_y1 = box2[1], box2_x1 = box2[2], box2_y2 = box2[3], box2_x2 = box2[4];

 //  assert(box1_y1 < box1_y2 && box1_x1 < box1_x2);
 //  assert(box2_y1 < box2_y2 && box2_x1 < box2_x2);
   
   float inter_y1 = std::max(box1_y1,box2_y1);
   float inter_x1 = std::max(box1_x1,box2_x1);
   float inter_y2 = std::min(box1_y2,box2_y2);
   float inter_x2 = std::min(box1_x2,box2_x2);

   float IOU = 0.0f;

   if((inter_y1 < inter_y2) && (inter_x1 < inter_x2)) //there is a valid intersection
   {
	float intersect = AREA(inter_y1, inter_x1, inter_y2, inter_x2);
	float total = AREA(box1_y1, box1_x1, box1_y2, box1_x2)
                     + AREA(box2_y1, box2_x1, box2_y2, box2_x2)
                     - intersect;
	IOU = total > 0.0f ? (intersect/total) : 0.0f;
   }
   return IOU;
}

void insertSelected(std::vector<std::vector<float>> &selected, std::vector<std::vector<float>> &selectedAll,
                std::vector<float>  & cand, const float& thres,
                std::vector<float>& classmap)
{       
        for(int i = 0; i < selected.size(); i++)
        {       
                if(computeIOU(&cand[0], &selected[i][0]) > thres){
                        return;
                }
        }
        cand[SCORE_POSITION] = cand[5];
#if MAP_CLASSES
        cand[CLASS_POSITION] = classmap[cand[CLASS_POSITION]];
#endif
        
        selected.push_back(cand);
        selectedAll.push_back(cand);
}
void insertSelected_fp16(std::vector<std::vector<float>> &selected, std::vector<std::vector<float>> &selectedAll,
                std::vector<float>  & cand, const float& thres, std::vector<uint16_t>& scores, int index,
                std::vector<float>& classmap)
{
        for(int i = 0; i < selected.size(); i++)
        {
                if(computeIOU(&cand[0], &selected[i][0]) > thres){
                        return;
                }
        }
        cand[SCORE_POSITION] = fp16_ieee_to_fp32_value(scores[index]);
#if MAP_CLASSES
        cand[CLASS_POSITION] = classmap[cand[CLASS_POSITION]];
#endif
        selected.push_back(cand);
        selectedAll.push_back(cand);
}
void NMS_fp32(std::vector<std::vector<float>> &boxes,
                const float& thres, const int& max_output_size,
                std::vector<std::vector<float>> &selected,
                std::vector<std::vector<float>> &selectedAll,
                std::vector<float>& classmap)
{
        std::sort(std::begin(boxes), std::end(boxes),
                        [&](const auto& a, const auto& b)
                        {
                        return (a[5] > b[5]) ;
                        });
        for(int i = 0; (i < boxes.size()) && (selected.size() < max_output_size); i++)
        {
                insertSelected(selected, selectedAll, boxes[i], thres, classmap);
        }
}

void NMS_fp16(std::vector<std::vector<float>> &boxes, std::vector<uint16_t>& scores,
                const float& thres, const int& max_output_size,
                std::vector<std::vector<float>> &selected,
                std::vector<std::vector<float>> &selectedAll,
                std::vector<float>& classmap)
{
        std::vector<std::pair<std::vector<float>,uint16_t>> packed;
        //assert(boxes.size() == scores.size());
        pack(boxes, scores, packed);

        std::sort(std::begin(packed), std::end(packed),
                        [&](const auto& a, const auto& b)
                        {
                        return (a.second > b.second);
                        });
        unpack(packed, boxes, scores);
        for(int i = 0; (i < boxes.size()) && (selected.size() < max_output_size); i++)
        {
                insertSelected_fp16(selected, selectedAll, boxes[i], thres, scores, i, classmap);
        }
}
