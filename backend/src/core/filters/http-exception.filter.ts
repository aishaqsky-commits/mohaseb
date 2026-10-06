import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response, Request } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : (exception as any)?.message || 'Internal server error';

    this.logger.error(
      `HTTP ${status} on ${request.method} ${request.url}: ${JSON.stringify(message)}`,
      (exception as any)?.stack,
    );

    response.status(status).json({
      success: false,
      statusCode: status,
      error: typeof message === 'object' ? message : { message },
      path: request.url,
      timestamp: new Date().toISOString(),
    });
  }
}
