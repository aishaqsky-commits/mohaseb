import { Body, Controller, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AiService } from './ai.service';
import { ParseIntentDto, ProposeEntryResponseDto } from './dto/ai-intent.dto';

@ApiTags('ai-assistant')
@ApiBearerAuth()
@Controller('api/v1/ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('parse-intent')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'تحليل النص أو الصوت واقتراح قيد محاسبي مزدوج (AI Intent Parser)',
    description: 'يستخرج نوع العملية، الأطراف، المبالغ، ويقترح قيداً متوازناً مع فرض مبدأ Human-in-the-Loop.',
  })
  @ApiResponse({
    status: 200,
    description: 'تم تحليل النص واقتراح القيد بنجاح',
    type: ProposeEntryResponseDto,
  })
  async parseIntent(@Body() dto: ParseIntentDto): Promise<ProposeEntryResponseDto> {
    return this.aiService.parseIntent(dto);
  }
}
